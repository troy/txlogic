module Txlogic
  class SipParticipant < TropoBaseParticipant
    DEFAULT_TIMEOUT = 30
    
    def first_choice
      1
    end

    def consume(workitem)
      reply_to_engine(workitem) && return unless workitem.params['recipient']
    
      super(workitem, 'VOIP', "sip:#{workitem.params['recipient']}")
    end
  end
end
