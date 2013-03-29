require 'spec_helper'

describe RuoteUtilities do
  it "converts 5m to seconds" do
    RuoteUtilities.timeout_in_seconds('5m').should eq(300)
  end
end
