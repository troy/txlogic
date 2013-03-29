class SilencedRecipient < ActiveRecord::Base
  validates_presence_of :recipient
  validates_presence_of :expires_at
  validates_presence_of :delivery_method
  
  def self.silence(recipient, network, duration)
    seconds = RuoteUtilities.timeout_in_seconds(duration)
    
    raise ArgumentError, 'Silence duration not provided' unless seconds
    
    expires_at = Time.now+seconds.seconds
      
    delivery_methods_to_silence(network).each do |method_to_silence|      
      Rails.logger.info "Silencing #{recipient} via #{method_to_silence} until #{expires_at}"
      
      silenced_recipient = new(:delivery_method => method_to_silence, :expires_at => expires_at)

      if method_to_silence == 'SMS' || method_to_silence == 'PSTN'
        silenced_recipient.recipient = PhoneNumber.new(recipient).to_e164
      else
        silenced_recipient.recipient = recipient
      end
      silenced_recipient.save
    end
  end
  
  def self.find_by_delivery_settings(recipient, network)
    expire
    find_by_recipient_and_delivery_method(recipient, AlertDelivery.to_delivery_method(network))
  end

  def self.expire
    delete_all([ 'expires_at < ?', Time.now ])
  end

  def self.delivery_methods_to_silence(tropo_network_name)
    # if someone silences SMS, also silence phone calls.
    # also, tropo says "VOIP", we say "SIP"
    return Array(tropo_network_name) unless ['SMS', 'PSTN', 'VOIP'].include?(tropo_network_name)
    
    if tropo_network_name == 'SMS' || tropo_network_name == 'PSTN'
      ['SMS', 'PSTN']
    elsif tropo_network_name == 'VOIP'
      Array('SIP')
    end
  end  
end
