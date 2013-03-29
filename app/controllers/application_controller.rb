class ApplicationController < ActionController::Base
  #before_filter :ensure_domain
  #before_filter :ensure_ssl
  before_filter :authenticate_user!

  protect_from_forgery
  
  #APP_DOMAIN = 'mydomain.com'
  #def ensure_domain
  #  if Rails.env.production? && request.env['HTTP_HOST'] != APP_DOMAIN
  #    redirect_to "https://#{APP_DOMAIN}", :status => 301
  #  end
  #end
  
  #def ensure_ssl
  #  unless request.ssl? || Rails.env.development? || Rails.env.test?
  #    redirect_to :protocol => 'https'
  #  end
  #end

  protected
  def shutdown_if_idle
    sleep(0.1)
    
    if $alerter.engine.processes.empty?
      $alerter.engine.errors.each do |err|
        raise_alert_error(err.inspect)
      end
      
      $alerter.engine.shutdown && $alerter = nil
    end
  end
  
  def current_customer
    current_user && current_user.customer
  end
  
  def raise_alert_error(message)
    # raise, notify exception reporting service, etc
    # raise RuntimeError.new(message)
  end
end
