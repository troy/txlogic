class AlertDelivery < ActiveRecord::Base
  belongs_to :alert
  has_many :reply_choices, :dependent => :destroy
  
  validates_presence_of :alert_id
  validates_presence_of :recipient
  validates_presence_of :delivery_method

  before_create :set_slug
  
#  default_scope order('alert_deliveries.id ASC')
  
  def self.to_delivery_method(tropo_network)
    tropo_network == 'VOIP' ? 'SIP' : tropo_network
  end
  
  def self.find_by_reply(sender, network, reply_choice)
    # only used when we don't explicitly receive the alert ID with the reply
    if network == 'SMS' || network == 'PSTN'
      formatted_sender = PhoneNumber.new(sender).to_e164
    else
      formatted_sender = sender
    end

    find(:first,
      :conditions => ['delivery_method = ? AND recipient = ? AND alerts.resolution IS NULL AND reply_choices.reply = ?', 
        to_delivery_method(network),
        formatted_sender,
        reply_choice ],
      :order => 'alert_deliveries.id DESC', :include => [ :alert, :reply_choices ])
  end
  
  def create_reply_choices(choices)
    choices.each do |choice_number, choice_meaning|
      reply_choices.build :reply => choice_number
    end
  end
  
  def resolve(reply)
    update_attribute(:reply, reply) if reply.present?
  end
  
  def formatted_delivery_method
    case delivery_method
    when 'JABBER', 'YAHOO'
      return delivery_method.capitalize
    when 'PSTN'
      return 'Call'
    when 'GTALK'
      return 'GTalk'
    end

    delivery_method
  end
  
  def accessible_anonymously?
    created_at > 1.hour.ago
  end
  
  protected
  def set_slug
    self.slug ||= SecureRandom.hex(4)
    true
  end
end
