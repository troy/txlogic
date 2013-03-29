class PagesController < ApplicationController
  layout "sign"
  
  skip_before_filter :authenticate_user!
  
  def index
    redirect_to alerts_path if user_signed_in?
  end
end
