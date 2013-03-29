module Txlogic
  class NotifyParticipant < Base
    def initialize(opts)
      @opts = opts.inject({}) { |h, (k, v)| h[k.to_s] = v; h }
    end

    def consume(workitem)
      @workitem = workitem
      
      svc = @workitem.params['recipient']

      if !svc.present?
        reply_to_engine(@workitem)
        return
      else
        svc = svc.strip.downcase
      end
      
      a_d = AlertDelivery.create! :alert_id => @workitem.fields['alert_id'], 
        :workitem_id => @workitem.fei.to_storage_id, 
        :recipient => svc,
        :delivery_method => 'HTTP'
      
      if silenced?(svc, 'HTTP')
        a_d.silenced = true
        a_d.save
        reply_to_engine(@workitem)
        return
      end

      template_values = @workitem.to_h
      template_values['fields']['workitem_id'] = @workitem.fei.to_storage_id
      template_values['fields']['url'] = alert_delivery_url(a_d)
      
      text = render_template(
        @opts['template'],
        Ruote::Exp::FlowExpression.fetch(@context, @workitem.fei.to_h),
        template_values)

      data = @workitem.params['settings']
      payload = {
        :compare => alert_delivery_url(a_d),
        :pusher => {
          :name => text
        },
        :repository => {
          :name => @workitem.fields['alert_process_name']
        }, 
        :commits => []
      }

      Faraday.post URI.join(Settings.alerts.services.base_url, "#{svc}/push"),
        { :payload => payload.to_json, :data => data.to_json }

      super
    end
  end
end
