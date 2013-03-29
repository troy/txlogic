module Txlogic
  class Base < Ruote::StorageParticipant
    include Ruote::LocalParticipant
    include Ruote::TemplateMixin
    
    MAX_CHOICE = 97

    def self.evaluate_reply(context, workitem, reply_text)
      return unless reply_text.to_i > 0
      
      # choice = Ruote::ReceiverMixin.get(workitem.fei, reply_text)
      # I can't call that mixin method #get from here, so I'm accessing
      # the stash hash directly
      fexp = Ruote::Exp::FlowExpression.fetch(context, workitem.fei.to_h)
      stash = fexp.h['stash'] rescue {}

      case stash[reply_text]
      when 'accept'
        [ :stop, 'Accepted' ]
      when 'decline'
        [ :continue, 'Declined' ]
      when 'stop'
        [ :stop, 'Ended' ]
      end
    end

    def silenced?(recipient, network)
      SilencedRecipient.find_by_delivery_settings(recipient, network).present?
    end

    def consume(*args)
      super
    ensure
      ActiveRecord::Base.connection_pool.release_connection
    end
    
    def first_choice
      c = rand(MAX_CHOICE)
      while c == 0
        c = rand(MAX_CHOICE)
      end
      c
    end
    
    def choice_set(base = nil)
      base ||= first_choice
      
      base = 1 if Rails.env.test?
      
      choices = { 
        base.to_s     => 'accept',
        (base+1).to_s => 'decline',
        (base+2).to_s => 'stop'
      }

      put(@workitem.fei, choices)

      choices
    end
    
    def choices_as_phrase(choices)
      choices.sort.map { |k,v| "#{k} to #{v}" }.join(', ')  
#      choices.sort { |a,b| a.to_i <=> b.to_i }.map { |k,v| "#{k} to #{v}" }.join(', ')
    end

    def reply_to_engine(workitem)
      # this is only called if a participant was incomplete or
      # couldn't be sent
      alert_delivery = AlertDelivery.find_by_workitem_id(workitem.fei.to_storage_id)
      alert_delivery.update_attribute(:reply, 'Format error') if alert_delivery
      
      super
    end
    
    def alert_delivery_url(a_d)
      URI.join(Settings.alerts.reply_base_url, "a/#{a_d.slug}")
    end
  end
end
