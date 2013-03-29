class RepliesController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :ensure_ssl, :only => :tropo
  before_filter :create_alerter
  after_filter :shutdown_if_idle

  def tropo
    Rails.logger.info "Received tropo reply: #{params[:reply]} about #{params[:workitem_id]} (#{params[:network]})"
    
    unless process_message(params[:sender], params[:network], params[:reply], params[:workitem_id])
      render(:status => :unprocessable_entity, :nothing => true) && return
    end
    
    render :status => 200, :nothing => true
  end
  
  def mailgun
    # format: update-0_0!66535fda4d9f48406d6f5399e99648e9!20110725-birunaje@txlogic.mailgun.org
    workitem_matches = params[:recipient].match(/update-(.*)@/)
        
    Rails.logger.info "Received mailgun reply: #{params['body-plain']} about #{workitem_matches[1]} from #{params[:sender]}"
    
    unless workitem_matches && workitem_matches.length == 2 && process_message(params[:sender], 'email', params['body-plain'], workitem_matches[1]) 
      render(:status => :unprocessable_entity, :nothing => true) && return
    end

    render :status => 200, :nothing => true
  end

  protected  
  def create_alerter
    $alerter ||= Alerter.new
  end
  
  def process_message(sender, network, message, workitem_id = nil)
    if sender && message_matches = message.match(/^s\w* (\S+)/)
      SilencedRecipient.silence(sender, network, message_matches[1]) if message_matches.length >= 2
    elsif body_matches = message.match(/^(\d+)/)
      reply_choice = body_matches[1]
      unless workitem_id
        workitem_id = AlertDelivery.find_by_reply(sender, network, reply_choice).try(:workitem_id)
      end
      $alerter.submit_participant_reply(workitem_id, reply_choice) if body_matches.length >= 2 && reply_choice.to_i > 0

    else
      raise_alert_error("Could not find command or workitem ID in #{message}")
      return false
    end
    
    true
  end
end
