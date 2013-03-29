module Txlogic
  class EmailParticipant < Base
    # derived from SmtpParticipant

    def initialize(opts)
      @opts = opts.inject({}) { |h, (k, v)| h[k.to_s] = v; h }
    end

    def consume(workitem)
      @workitem = workitem
      
      to = @workitem.params['recipient']
      to = Array(to)

      if !to.present? 
        reply_to_engine(@workitem)
        return
      end

      a_d = AlertDelivery.create! :alert_id => @workitem.fields['alert_id'], 
        :workitem_id => @workitem.fei.to_storage_id, 
        :recipient => to.join(', '),
        :delivery_method => 'email'
      
      if silenced?(@workitem.params['recipient'], 'email')
        a_d.silenced = true
        a_d.save
        reply_to_engine(@workitem)
        return
      end

      choices = choice_set
      a_d.create_reply_choices(choices)
      
      template_values = @workitem.to_h
      template_values['fields']['choices'] = choices_as_phrase(choices)
      template_values['fields']['workitem_id'] = @workitem.fei.to_storage_id
      template_values['fields']['recipient'] = @workitem.params['recipient']
      template_values['fields']['url'] = alert_delivery_url(a_d)
      
      text = render_template(
        @opts['template'],
        Ruote::Exp::FlowExpression.fetch(@context, @workitem.fei.to_h),
        template_values)

      a_d.save!

      smtp_settings = Settings.alerts.email.smtp

      Net::SMTP.start(smtp_settings.address, smtp_settings.port,
        smtp_settings.domain, smtp_settings.user_name, smtp_settings.password,
        smtp_settings.authentication) do |smtp|
          smtp.send_message(text, @opts['from'], *to)
      end

      super
      
    end
  end
end
