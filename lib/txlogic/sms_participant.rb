module Txlogic
  class SmsParticipant < TropoBaseParticipant
    def self.truncate_to
      148
    end
    
    def consume(workitem)
      reply_to_engine(workitem) && return unless workitem.params['recipient'] && workitem.params['recipient'].length == 10
      
      super(workitem, 'SMS', PhoneNumber.new(workitem.params['recipient']))
    end
  end
end
