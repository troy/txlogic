require 'spec_helper'

describe "an Alert" do
  context "that is resolved" do
    it "identifies the correct resolver" do
      alerts(:incomplete_participant_resolved).resolver.should eq('resolver@domain.com')
    end
  end
    
  context "that is active" do
    before do
      @process_definition = process_definitions(:sms)
    end
    
    it "is created" do
      expect {
        Alert.create :process_definition => @process_definition
      }.to change(Alert, :count).by(1)
    end
    
    it "is run" do
      Alert.create(:process_definition => @process_definition).running?.should eq(true)
    end
  end
  
  context "that is paused" do
    before do
      @process_definition = process_definitions(:paused)
      @alert = @process_definition.alerts.new :subject => 'woo', :message => 'narf'
    end

    it "does not create an AlertDelivery" do
      expect {
        @alert.kickoff
      }.to change(AlertDelivery, :count).by(0)
    end
    
    it "is immediately resolved" do
      @alert.kickoff
      @alert.resolution.should eq("Not sent (process paused)")
    end
  end
  
  context "that matches a subject filter" do
    before do
      @process_definition = process_definitions(:incomplete_participant)
      @alert = @process_definition.alerts.new :message => 'narf', :subject => '[Scout] pt01d02 Back to normal:  Disk Space Available decreased 45 GB (-33.5%) from 134 GB to 89 GB from 01:00AM-04:00AM relative to previous 7 days and continued until 02:00AM (about 22\thours)'
    end
        
    it "does not create an AlertDelivery" do
      @alert = @process_definition.alerts.new :message => 'narf', :subject => '[Scout] pt01d02 Back to normal:  Disk Space Available decreased 45 GB (-33.5%) from 134 GB to 89 GB from 01:00AM-04:00AM relative to previous 7 days and continued until 02:00AM (about 22\thours)'
      expect {
        @alert.kickoff
      }.to change(AlertDelivery, :count).by(0)
    end
    
    it "is immediately resolved" do
      @alert.kickoff
      @alert.resolution.should eq("Not sent (subject filter)")
    end
  end
end