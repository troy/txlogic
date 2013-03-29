module Txlogic
  class TropoBaseParticipant < Base
    SUPPORTED_IM_NETWORKS = %w(AIM GTALK JABBER MSN YAHOO)
    DEFAULT_TIMEOUT = 120

    def self.truncate_to
      1000
    end
    
    def initialize(opts)
      @opts = opts.inject({}) { |h, (k, v)| h[k.to_s] = v; h }
    end

    def consume(workitem, network, recipient)
      @workitem = workitem

      cdr_recipient = recipient.is_a?(PhoneNumber) ? recipient.to_e164 : recipient

      a_d = AlertDelivery.create! :alert_id => @workitem.fields['alert_id'], 
        :workitem_id => @workitem.fei.to_storage_id, 
        :recipient => cdr_recipient,
        :delivery_method => AlertDelivery.to_delivery_method(network)

      template_values = @workitem.to_h

      @choices = choice_set
      a_d.create_reply_choices(@choices)      
      template_values['fields']['choices'] = choices_as_phrase(@choices)

      template_values['fields']['url'] = alert_delivery_url(a_d)

      if silenced?(cdr_recipient, network)
        a_d.silenced = true
        a_d.save
        reply_to_engine(@workitem)
        return
      end

      message_length = self.class.truncate_to
      message_length -= template_values['fields']['url'].length
      message_length -= template_values['fields']['choices'].length
      message_length -= 5 # punctuation

      if template_values['fields']['subject'].length > message_length
        template_values['fields']['subject'] = template_values['fields']['subject'][0..message_length]
        template_values['fields']['message'] = ''
      else
        message_length -= template_values['fields']['subject'].length
        template_values['fields']['message'] = template_values['fields']['message'][0..message_length]
      end

      text = render_template(
        @opts['template'],
        Ruote::Exp::FlowExpression.fetch(@context, @workitem.fei.to_h),
        template_values)
        

      tropo_params = { 
        'action'  => 'create', 
        'token'   => Settings.alerts.tropo.token,
        'recipient'   => recipient.is_a?(PhoneNumber) ? recipient.to_tropo_destination : recipient,
        'network' => network,
        'choices' => @choices.keys.join(','),
        'msg'     => network == 'SMS' ? text[0..158] : text,
        'timeout' => @workitem.params['timeout'] ? RuoteUtilities.timeout_in_seconds(@workitem.params['timeout']) : DEFAULT_TIMEOUT,
        'workitem_id' => @workitem.fei.to_storage_id
      }

      a_d.save

      Faraday.get "http://api.tropo.com/1.0/sessions?" + tropo_params.to_param

      super(workitem)
    end
  end
end
