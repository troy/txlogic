class AlertsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [ :create ]
    
  def index
    @process_definitions = current_customer.process_definitions.all

    @alerts = Alert.where(:process_definition_id => @process_definitions).paginate(:page => params[:page])
    @active_alerts = @alerts.map(&:running?).include?(true)
  
    respond_to do |format|
      format.html
      format.json do 
        render :json => @alerts.to_json(:only => [ :id, :subject, 
          :message, :created_at, :updated_at, :resolution ])
      end
    end
  end
  
  def show
    @alert = current_customer.alerts.includes(:deliveries).find(params[:id])
  end
  
  def create
    launch_alias = nil  
    message = ''
    
    @alert = Alert.new
    
    if params[:alert]
      @alert = Alert.new(params[:alert])
    elsif params[:recipient]
      launch_alias_matches = params[:recipient].match(/alert-(.*)@/)
      launch_alias = launch_alias_matches[1]
      @alert.message = params['body-plain']
    elsif params[:message]
      @alert.message = params[:message]
    elsif params[:payload]
      @alert.message = JSON.pretty_generate(JSON.parse(params[:payload]))
    end
    
    @alert.subject ||= params[:subject] || ''
    @alert.subject = @alert.subject[0..254]
  
    if !@alert.process_definition
      @alert.process_definition = ProcessDefinition.find_by_launch_alias(launch_alias || params[:id])
    end

    Rails.logger.info "Starting #{@alert.process_definition.inspect}"
    
    # move to callback
    success = @alert.kickoff
    
    if success && params[:alert]
      # human
      flash[:notice] = 'Alert invoked.'
      redirect_to alerts_path
    elsif success
      render(:status => 200, :nothing => true)
    else
      render(:status => 412, :nothing => true)
    end
  end
  
  def accept
    @alert = current_customer.alerts.unresolved.find(params[:id])
    
    @alert.accept(current_user.email)

    flash[:notice] = 'Alert accepted.'
    redirect_to alerts_path
  end

  def stop
    @alert = current_customer.alerts.unresolved.find(params[:id])
    
    @alert.cancel(current_user.email)
        
    flash[:notice] = 'Alert ended.'
    redirect_to alerts_path
  end
end
