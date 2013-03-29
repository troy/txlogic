class PhoneNumber < String  
  def initialize(phone_number)
    if phone_number =~ /^tel:/
      super(phone_number.sub(/^tel:/, ''))
    elsif phone_number.length == 12
      super(phone_number)
    elsif phone_number.length == 11
      super("+#{phone_number}")
    elsif phone_number.length == 10
      super("+1#{phone_number}")
    else
      raise ArgumentError
    end
  end
  
  def to_e164
    self
  end
  
  def to_tropo_destination
    "tel:#{self}"
  end

  def to_us_number(delim = nil)
    if delim
      m = match(/^\+1(\d{3})(\d{3})(\d{4})/)
      m[1..3].join(delim)
    else
      sub(/^\+1/, '')
    end
  end
end