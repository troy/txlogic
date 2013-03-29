class Alert < ActiveRecord::Base
  belongs_to :customer
  belongs_to :process_definition
  has_many   :deliveries,  :class_name => 'AlertDelivery', :dependent => :destroy, :order => 'id DESC'
  belongs_to :resolved_by, :class_name => 'AlertDelivery'

  before_create :set_customer_from_process_definition

  validates_presence_of :process_definition_id
  
  default_scope order('id DESC')  
  scope :unresolved, :conditions => { :resolution => nil }
  
  cattr_reader :per_page
  @@per_page = 10
  
  def kickoff
    save! if new_record?
    
    return true if handled_locally?
    
    $alerter ||= Alerter.new
    
    $alerter.kickoff(process_definition.runnable_process,
      process_definition.time_zone,
      'alert_id' => id, 'alert_process_name' => process_definition.name,
      'subject' => subject, 'message' => message,
      'url' => URI.join(Settings.alerts.reply_base_url, "alerts/#{id}"),
      'tz' => process_definition.time_zone)
  end
  
  def running?
    !resolution && (updated_at > 30.minutes.ago)
  end
  
  def resolver
    read_attribute(:resolver) || (resolved_by && resolved_by.recipient)
  end
  
  def most_recent_delivery_workitem_id
    deliveries.find(:first, :conditions => [ 'workitem_id IS NOT NULL' ]).try(:workitem_id)
  end

  def accept(username)
    $alerter ||= Alerter.new
    
#    begin
      $alerter.cancel_process(most_recent_delivery_workitem_id)
#    rescue ArgumentError
#    end
    update_attribute(:resolution, 'Accepted')
    update_attribute(:resolver, username)
  end
  
  def cancel(username)
    $alerter ||= Alerter.new
    
#    begin
      $alerter.cancel_process(most_recent_delivery_workitem_id)
#    rescue ArgumentError
#    end
    update_attribute(:resolution, 'Ended')
    update_attribute(:resolver, username)
  end
  
  protected
  def handled_locally?
    if !process_definition.active
      self.resolution = 'Not sent (process paused)'
    elsif process_definition.filter_alert?(self)
      self.resolution = 'Not sent (subject filter)'
    else
      return false
    end

    save
    true
  end

  def set_customer_from_process_definition
    self.customer_id ||= process_definition.customer_id
  end
end
