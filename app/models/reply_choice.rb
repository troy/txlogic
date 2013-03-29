class ReplyChoice < ActiveRecord::Base
  belongs_to :alert_delivery
  
  validates_presence_of :alert_delivery_id
  validates_presence_of :reply
  validates_uniqueness_of :reply, :scope => :alert_delivery_id
end
