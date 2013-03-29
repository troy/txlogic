class Alerter
  attr_reader :engine
    
  def initialize
#    ENGINE.register_participant('trace') do |workitem|
#      (workitem.fields['trace'] ||= []) << [
#        Time.now.strftime('%Y-%m-%d %H:%M:%S'),
#        workitem.fields['next'],
#        workitem.fields['task'] ]
#    end
    @engine = Ruote::Engine.new(Ruote::Worker.new(Ruote::HashStorage.new))
    @engine.register_participant(
      /^email .+/i,
      Txlogic::EmailParticipant,
      :from => Settings.alerts.email.from,
      :template => "Subject: [TxL] ${f:subject}\nFrom: Transmit Logic <#{Settings.alerts.email.from}>\nReply-To: Transmit Logic <update-${f:workitem_id}@#{Settings.alerts.email.reply_domain}>\nTo: ${f:recipient}\n\n${f:message}\n\n--- TRANSMIT LOGIC ---\n  Respond: ${f:url}\n  Reply options: ${f:choices}\n")

    @engine.register_participant(
      /^sms .+/i,
      Txlogic::SmsParticipant,
      :template => "${f:subject}. ${f:message}. ${f:url} or reply ${f:choices}")

    @engine.register_participant(
      /^im .+/i,
      Txlogic::ImParticipant,
      :template => "Alert: ${f:subject}. ${f:message}. Visit ${f:url} or reply ${f:choices}")

    @engine.register_participant(
      /^call .+/i,
      Txlogic::CallParticipant,
      :template => "Alert about ${f:subject}. Details follow. Press ${f:choices}. ${f:message}. Press ${f:choices}.")

    @engine.register_participant(
      /^sip .+/i,
      Txlogic::SipParticipant,
      :template => "Alert about ${f:subject}. Details follow. Press ${f:choices}. ${f:message}. Press ${f:choices}.")

    @engine.register_participant(
      /^notify .+/i,
      Txlogic::NotifyParticipant,
      :template => "Alert: ${f:subject}.")
  end
  
  def kickoff(pdef, tz, options, noisy = false)
    @engine.noisy = noisy

    t = Time.now.in_time_zone(ActiveSupport::TimeZone.new(tz))
    # Sat & Sun
    weekend = t.wday == 6 || t.wday == 0
    # 7am-6:59pm
    daytime = t.hour >= 7 && t.hour < 19
    @engine.launch(pdef, options.merge(:hour => t.hour, :minute => t.min,
      :day => t.day, :month => t.month, :day_of_week => t.wday,
      :day_of_year => t.yday, :weekend => weekend, :weekday => !weekend,
      :daytime => daytime, :nighttime => !daytime))
  end
  
  def wait_for(wfid)
    @engine.wait_for(wfid)  
  end
  
  def retrieve_workitem(id)
    fei = Ruote::FlowExpressionId.from_id(id, 
      @engine.context.engine_id)
    @engine.storage_participant[fei]
  end
  
  def cancel_root_process(workitem)
    parent = workitem.wfid.split('!').last
    @engine.cancel(parent)
  end
  
  def cancel_process(workitem_storage_id)

    workitem = retrieve_workitem(workitem_storage_id)
    raise ArgumentError, 'workitem not found' unless workitem
    
    cancel_root_process(workitem)
  end
  
  def submit_participant_reply(workitem_storage_id, reply_text)
    workitem = retrieve_workitem(workitem_storage_id)
    alert_delivery = AlertDelivery.find_by_workitem_id(workitem_storage_id)

    if !alert_delivery
      return :not_found
    elsif !workitem
      # already ended on its own or from someone else's reply
      alert_delivery.resolve('Responded after alert ended')
      return :already_ended
    end
    
    reply_result, reply_label = Txlogic::Base.evaluate_reply(@engine.context, workitem, reply_text)

    alert = alert_delivery.alert
    # if the reply says to, either stop the process or the participant (by 
    # returning the workitem)
    if reply_result == :stop
      cancel_root_process(workitem)
      alert.resolution = reply_label
      alert.resolved_by = alert_delivery
      alert.save
    elsif reply_result == :continue
      @engine.storage_participant.reply(workitem)
    end
    
    alert_delivery.resolve(reply_label)

    reply_result
  end
end
