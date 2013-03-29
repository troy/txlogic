class UserMailer < ActionMailer::Base
  include Devise::Mailers::Helpers
  
  def member_invitation(record)   
    devise_mail(record, :member_invitation)
  end
end
