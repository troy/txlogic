class User < ActiveRecord::Base
  INVITATION_CODE = 'its5oclocksomewhere'
  
  belongs_to :customer
  accepts_nested_attributes_for :customer

  before_validation :create_new_customer, :on => :create
  
  #validates_presence_of :customer_id
  validate :valid_invitation_code, :on => :create
    
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable

  attr_accessor :invitation_code
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :invitation_code

  def send_member_invitation
    generate_reset_password_token! if should_generate_reset_token?
    UserMailer.member_invitation(self).deliver
  end
  
  private
  def valid_invitation_code
    errors.add(:base, 'Wrong invitation code') unless invitation_code == INVITATION_CODE
  end
  
  def create_new_customer
    self.customer ||= self.build_customer
  end
end
