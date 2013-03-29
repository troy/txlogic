module Txlogic
  class ImParticipant < TropoBaseParticipant
    def consume(workitem)
      using = workitem.params['using']
      unless workitem.params['recipient'] && using && SUPPORTED_IM_NETWORKS.include?(using.upcase)
        reply_to_engine(workitem)
        return
      end

      super(workitem, using.upcase, workitem.params['recipient'])
    end
  end
end
