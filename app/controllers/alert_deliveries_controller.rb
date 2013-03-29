class AlertDeliveriesController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [ :show ]
  
  def show
    @alert_delivery = AlertDelivery.find_by_slug(params[:id])

    if !user_signed_in? && !@alert_delivery.accessible_anonymously?
      redirect_to new_user_session_path
      return
    end

    if @alert_delivery.accessible_anonymously?
      @alert = Alert.includes(:deliveries).find(@alert_delivery.alert_id)
    else
      @alert = current_customer.alerts.includes(:deliveries).
                                find(@alert_delivery.alert_id)
    end

    flash[:notice] = 'Login to respond to this alert.' unless user_signed_in?
    render template: 'alerts/show'
  end
end
