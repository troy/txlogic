require 'securerandom'

class MembersController < ApplicationController
  def index
    @users = current_customer.users.all
    
    @user = current_customer.users.build
  end
  
  def create
    pw = SecureRandom.hex(8)
    @user = current_customer.users.build :email => params[:user][:email], 
      :password => pw, :password_confirmation => pw,
      :invitation_code => User::INVITATION_CODE
    # does not do mass assignment
    @user.confirmed_at = Time.now

    if @user.save && @user.send_member_invitation
      flash[:info] = "Invitation email sent."
    else
      flash[:error] = "Sorry, an error occurred."
    end

    respond_to do |format|
      format.html { redirect_to members_path }
    end 
  end
  
  def destroy
    @user = current_customer.users.find params[:id]

    if @user != current_user && @user.destroy
      flash[:info] = "User removed."
    elsif @user == current_user
      flash[:error] = "Can't delete yourself, even on a bad day."
    else
      flash[:error] = "Sorry, an error occurred."
    end

    respond_to do |format|
      format.html { redirect_to members_path }
    end
  end
end
