require 'spec_helper'

describe 'a SilencedRecipient' do
  it "is created from a customer silence request" do
    expect {
      @silenced_recipient = SilencedRecipient.silence('a@b.com', 'email', '30s')
    }.to change(SilencedRecipient, :count).by(1)
    
    SilencedRecipient.find_by_recipient('a@b.com').expires_at.should be <= 30.seconds.from_now
  end

  it "silences SMS and phone call methods based on an SMS silence request" do
    expect {
      @silenced_recipient = SilencedRecipient.silence('+14445556666', 'SMS', '30s')
    }.to change(SilencedRecipient, :count).by(2)
  end  
end

describe SilencedRecipient do
  it "expires outdated requests" do
    expect {
      SilencedRecipient.expire
    }.to change(SilencedRecipient, :count).by(-1)
  end
  
  it "finds a silenced recipient" do
    SilencedRecipient.find_by_delivery_settings('+12061112222', 'PSTN').should be
  end
  
  it "identifies methods to silence" do
    SilencedRecipient.delivery_methods_to_silence('SMS').should eq(['SMS', 'PSTN'])
  end
end
