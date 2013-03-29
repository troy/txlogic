class ProcessDefinitionsController < ApplicationController
  def show
    redirect_to edit_process_path(current_customer.process_definitions.find(params[:id]))
  end
  
  def new
    @process_definition = current_customer.process_definitions.build
  end
  
  def create
    @process_definition = current_customer.process_definitions.build(params[:process_definition])
    
    if @process_definition.save
      # this should be flash.now but web-app-theme doesn't honor it
      flash[:notice] = verifying? ? 'Valid. Saved.' : 'Created.'
          
      respond_to do |format|
        format.html { redirect_to(verifying? ? edit_process_path(@process_definition) : alerts_path) }
      end
    else
      flash[:error] = "Sorry, this process isn't valid or is incomplete. Trying to accomplish a workflow? Send us a note."
      render :new
    end
  end
  
  def edit
    @process_definition = current_customer.process_definitions.find(params[:id])
  end
  
  def update
    @process_definition = current_customer.process_definitions.find(params[:id])
    
    if @process_definition.update_attributes(params[:process_definition])
      # this should be flash.now but web-app-theme doesn't honor it
      flash[:notice] = verifying? ? 'Valid. Updated.' : 'Updated.'

      respond_to do |format|
        format.html { redirect_to(verifying? ? edit_process_path(@process_definition) : alerts_path) }
      end
    else
      flash[:error] = "Sorry, this process isn't valid or is incomplete. Trying to accomplish a workflow? Send us a note."
      render :edit
    end
  end
  
  def destroy
    respond_to do |format|
      if current_customer.process_definitions.find(params[:id]).destroy
        format.html do 
          flash[:notice] = 'Process deleted.'
          redirect_to alerts_path
        end
      else
        format.html do
          flash[:error] = 'Sorry, an error occurred while deleting this process. Please contact support.'
          redirect_to alerts_path
        end          
      end
    end    
  end
  
  def invoke
    @process_definition = current_customer.process_definitions.find(params[:id])
    @alert = @process_definition.alerts.build
  end
  
  def pause
    @process_definition = current_customer.process_definitions.find(params[:id])
    @process_definition.update_attribute(:active, false)
    
    redirect_to alerts_path
  end
  
  def resume
    @process_definition = current_customer.process_definitions.find(params[:id])
    @process_definition.update_attribute(:active, true)
    
    redirect_to alerts_path
  end
  
  private
  def verifying?
    params[:verify].present?
  end
end
