class ProcessDefinition < ActiveRecord::Base
  belongs_to :customer
  has_many :alerts, :dependent => :destroy

  validates_presence_of :customer_id  
  validates_presence_of :launch_alias
  validates_presence_of :definition
  validates_uniqueness_of :launch_alias
  
  default_scope order(:name)
  attr_protected :launch_alias, :definition
  
  before_validation :set_launch_alias, :on => :create
  validate :valid_syntax
  
  def to_s
    name
  end
  
  def time_zone
    read_attribute(:time_zone) || 'UTC'
  end

  def process_markup
    self.definition.sub(/^Ruote\./, '') if self.definition.present?
  end
  def process_markup=(new_markup)
    self.definition = "Ruote." + new_markup.strip
  end
  
  def runnable_process
    Ruote::Reader.read(definition)
  end
  
  def filter_alert?(alert)
    self.subject_filter.present? && alert.subject.present? && Regexp.new(self.subject_filter).match(alert.subject)
  end

  protected
  def set_launch_alias
    self.launch_alias = SecureRandom.hex(8)
  end
  
  def valid_syntax
    begin
      parsed = runnable_process
    rescue
      errors.add(:base, "Definition is invalid or incomplete")
      return false
    end
    
    if parsed.is_a?(Array)
      return true
    end
    
    errors.add(:base, "Definition is invalid or incomplete")    
    return false
  end  
end
