require 'net/http'
require 'uri'

log "Starting Scripting app"

# replace 2065551111 with your Tropo number
# replace YOUR-TXLOGIC-URL.COM with the URL to Transmit Logic

unless defined?($action) && $action == 'create'
  # unsolicited inbound w/o call state
  answer
  say "Got it." unless $currentCall.network == 'SMS'
  Net::HTTP.post_form(URI.parse('http://YOUR-TXLOGIC-URL.COM/replies/tropo'), 
    { :reply => $currentCall.initialText, :sender => $currentCall.callerID, :network => $currentCall.network })
  return  
end

# outbound
log "@"*10 + "Sending message to: " + $recipient + ": " + $msg

if $network == 'PSTN' || $network == 'VOIP'
  call $recipient, { :network  => $network, :callerID => '2065551111' }
  ask "Hello, this is Transmit Logic. Press 1 for an alert.", {
    :choices => "[1 DIGIT]",
    :timeout => 7,
    :mode => 'dtmf',
    :attempts => 2,
    :onTimeout => lambda { |event|
      return
    },
    :onChoice => lambda { |event|
      sleep 1
    }
  }
else
  call $recipient, { :network  => $network }
end

ask $msg, {
  :choices => "[1-2 DIGITS]",
  :timeout => $timeout.to_i,
  :mode => 'dtmf',
  :attempts => 1,
  :onChoice => lambda { |event|
    log "received reply " + event.value
    say "Got it." unless $currentCall.network == 'SMS'
    Net::HTTP.post_form(URI.parse('http://YOUR-TXLOGIC-URL.COM/replies/tropo'), 
      { :workitem_id => $workitem_id, :reply => event.value, :network => $currentCall.network })
  },
  :onBadChoice => lambda { |event|
    if event.value =~ /^s/i
      Net::HTTP.post_form(URI.parse('http://YOUR-TXLOGIC-URL.COM/replies/tropo'), 
        { :reply => event.value, :sender => $currentCall.callerID, :network => $currentCall.network })
    elsif $currentCall.network != 'SMS'
      say "Sorry, " + event.value + " is not a valid choice. I'm a simple monkey, so let's try once more. " + $msg
    end
  }
}

hangup
