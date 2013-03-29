module Txlogic
  class CallParticipant < TropoBaseParticipant
    DEFAULT_TIMEOUT = 30
    
    def first_choice
      1
    end

    def consume(workitem)
      reply_to_engine(workitem) && return unless workitem.params['recipient'] && workitem.params['recipient'].length == 10

      super(workitem, 'PSTN', PhoneNumber.new(workitem.params['recipient']))
    end
  end
end
