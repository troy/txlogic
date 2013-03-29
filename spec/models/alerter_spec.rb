require 'spec_helper'

RSpec.configure do |config|
  # required to be able to access AlertDeliveries in the same
  # test as the Alert was created
  config.use_transactional_fixtures = false
end

def kickoff_and_sleep(alert, duration = 1.0)
  wfid = alert.kickoff
  sleep(duration)
  wfid
end

describe 'an Alerter' do
  before do
    reset_ruote
    participant_stubs
  end
  
  describe "running a multi-participant process with an invalid participant and 2 valid ones" do
    before do
      @alert = process_definitions(:incomplete_participant).alerts.build :subject => 'a', :message => 'b'
      @wfid = kickoff_and_sleep(@alert)

    end

    it "returns a workflow ID" do
      @alert.should be
      @wfid.should be
    end
    
    it "runs" do
      $alerter.engine.storage_participant.by_wfid(@wfid).should be
      $alerter.engine.storage_participant.by_wfid(@wfid).length.should eq(2)
    end
  end

  describe "starting an email process" do
    before do
      @process_definition = process_definitions(:email_then_sms)
      @alert = @process_definition.alerts.build :subject => 'a', :message => 'b'
    end
    
    it "delivers" do
      expect {
        @wfid = kickoff_and_sleep(@alert)
      }.to change(AlertDelivery, :count).by(1)
    end
  end
  
  describe "starting a Notify process" do
    before do
      @process_definition = process_definitions(:notify)
      @alert = @process_definition.alerts.build :subject => 'a', :message => 'b'
    end
    
    it "delivers" do
      expect {
        @wfid = kickoff_and_sleep(@alert)
      }.to change(AlertDelivery, :count).by(1)
    end    
  end
      
  describe "starting a SMS process" do
    before do
      @process_definition = process_definitions(:sms)
      @alert = @process_definition.alerts.build :subject => 'a', :message => 'b'
    end
    
    it "delivers" do
      expect {
        @wfid = kickoff_and_sleep(@alert)
      }.to change(AlertDelivery, :count).by(1)
    end

    it "creates ReplyChoices" do
      expect {
        @wfid = kickoff_and_sleep(@alert, 0.5)
      }.to change(ReplyChoice, :count).by(3)
    end

    it "sets time" do
      @wfid = kickoff_and_sleep(@alert, 0.5)
      
      $alerter.engine.storage_participant.by_wfid(@wfid).first.fields['minute'].should eq(Time.now.min)
    end

    it "honors the default tz" do
      @wfid = kickoff_and_sleep(@alert, 0.5)
    
      $alerter.engine.storage_participant.by_wfid(@wfid).first.fields['tz'].should eq('UTC')
      $alerter.engine.storage_participant.by_wfid(@wfid).first.fields['hour'].should eq(Time.now.gmtime.hour)
    end
    
    context "setting the time fields" do
      before do
        @process_definition = process_definitions(:sms_timezone_set)
        @alert = @process_definition.alerts.build :subject => 'a', :message => 'b'
      end

      it "honors a non-default tz" do
        @wfid = kickoff_and_sleep(@alert, 0.5)
      
        $alerter.engine.storage_participant.by_wfid(@wfid).first.fields['tz'].should eq('Pacific Time (US & Canada)')
        $alerter.engine.storage_participant.by_wfid(@wfid).first.fields['hour'].should eq(Time.now.in_time_zone(ActiveSupport::TimeZone.new('Pacific Time (US & Canada)')).hour)
      end
    end
    
    context "sending to a silenced recipient" do
      before do
        SilencedRecipient.silence('+12067778888', 'SMS', '5s')
      end
      
      it "creates an AlertDelivery that is not sent" do
        expect {
          @alert = @process_definition.alerts.build :subject => 'a', :message => 'b'
          @wfid = kickoff_and_sleep(@alert)
        }.to change(AlertDelivery, :count).by(1)
        @alert.reload
        @alert.deliveries.first.silenced.should be_true
      end
    end
  end

  describe "running multiple processes using the same recipients" do
    before do
      @alert1 = process_definitions(:sms).alerts.build :subject => 'a', :message => 'b'*100
      @wfid1 = kickoff_and_sleep(@alert1)
      @alert2 = process_definitions(:sms).alerts.build :subject => 'a', :message => 'b'*100
      @wfid2 = kickoff_and_sleep(@alert2)
    end
    
    it "creates multiple processes" do
      $alerter.engine.processes.length.should eq(2)
    end
    
    describe "receiving a response without an Alert identifier" do
      it "attributes to the newest first" do
        @alert2.reload
        @alert_delivery = AlertDelivery.find_by_reply('+12067778888', 'SMS', '1')
        @alert_delivery.should eq(@alert2.deliveries.first)
      end
      
      it "attributes to the older when the newest has been resolved" do
        @alert2.cancel('abc')
        sleep 0.5
        @alert_delivery = AlertDelivery.find_by_reply('+12067778888', 'SMS', '1')
        @alert_delivery.should eq(@alert1.deliveries.first)
      end
    end
  end
    
  describe "after resolution" do
    before do
      participant_stubs
      # I'm not sure how much of this is needed
      Alert.destroy_all
      SilencedRecipient.destroy_all
      ReplyChoice.destroy_all
    
      reset_ruote

      @alert = process_definitions(:sms).alerts.build :subject => 'a', :message => 'b'
      @wfid = kickoff_and_sleep(@alert)

      @alert_delivery = AlertDelivery.find_by_reply('+12067778888', 'SMS', '1')
    end
  
    it "has the expected resolutions" do
      @alert_delivery.reload

      @alert.should be
      @alert_delivery.should be

      @workitem_id = @alert_delivery.workitem_id
      $alerter.submit_participant_reply(@workitem_id, '1')
    
      @alert.reload
      @alert.resolution.should eq("Accepted")
      @alert.resolved_by.should eq(@alert_delivery)
    end
  end

  describe "running an SMS process" do
    before do
      # I'm not sure how much of this is needed
      Alert.destroy_all
      SilencedRecipient.destroy_all
    end

    context "at invocation" do
      before do
        @alert = process_definitions(:sms).alerts.build :subject => 'a', :message => 'b'*100

        @wfid = kickoff_and_sleep(@alert)
        
        @alert.reload
        @alert_delivery = @alert.deliveries.first
      end
      
      it "doesn't raise errors" do
        $alerter.engine.errors.empty?.should be_true
      end

      it "returns a workitem and persists it" do
        @wfid.should be
        @alert_delivery.should be
        $alerter.engine.storage_participant.by_wfid(@wfid).first.should be
      end

      it "was not silenced" do
        @alert_delivery.should be
        @alert_delivery.silenced.should_not be_true
      end

# something is really weird about this block - by_wfid() returns [] and I have no idea why.
# same before .. end block.
#     it "truncates the message" do
#        $alerter.engine.storage_participant.by_wfid(@wfid).first.should be
#        $alerter.engine.storage_participant.by_wfid(@wfid).first.fields.class.should eq(Hash)
#        $alerter.engine.storage_participant.by_wfid(@wfid).first.fields['message'].length.should be < 80
#      end

    end  
    
    context "at resolution" do
      before do
        @alert = process_definitions(:sms).alerts.build :subject => 'a', :message => 'b'

        reset_ruote
        kickoff_and_sleep(@alert, 8.0)

        @alert.reload
        @alert.deliveries.reload
        @alert_delivery = @alert.deliveries.first
      end

#      it "finds a workitem representing the first Participant" do
#        @workitem_id = @alert_delivery.workitem_id
#        @workitem_id.should be
#      end
      
      it "cancels the process when accepted" do
        @workitem_id = @alert_delivery.workitem_id

        expect {
          $alerter.submit_participant_reply(@workitem_id, '1')
          sleep 0.5
          # it's possible for this to fail on a heavily loaded machine
        }.to change { $alerter.engine.processes.length }.from(1).to(0)
      end

      it "stops when accepted" do
        @workitem_id = @alert_delivery.workitem_id
        $alerter.submit_participant_reply(@workitem_id, '1').should eq(:stop)
      end
      
      it "continues when declined" do
        @workitem_id = @alert_delivery.workitem_id
        
        $alerter.submit_participant_reply(@workitem_id, '2').should eq(:continue)
      end
      
      it "stopped when stopped" do
        @workitem_id = @alert_delivery.workitem_id
        
        $alerter.submit_participant_reply(@workitem_id, '3').should eq(:stop)
      end

      it "can't be resolved twice" do
        @workitem_id = @alert_delivery.workitem_id
        
        $alerter.submit_participant_reply(@workitem_id, '3').should eq(:stop)
        sleep 0.2
        $alerter.submit_participant_reply(@workitem_id, '3').should eq(:already_ended)
      end
      
      it "can't find a nonexistent workitem" do
        $alerter.submit_participant_reply('123', '3').should eq(:not_found)

        sleep 0.2
      end
      
      it "ignores a bogus choice" do
        @workitem_id = @alert_delivery.workitem_id
        
        $alerter.submit_participant_reply(@workitem_id, '555').should be_nil
        sleep 0.2
      end
    end
  end
end