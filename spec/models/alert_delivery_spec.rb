require 'spec_helper'

describe 'an AlertDelivery' do
  context 'that already exists' do
    before do
      @alert_delivery = AlertDelivery.find_by_reply('12062223333', 'SMS', '42')
    end
  
    it "finds an active delivery" do
      @alert_delivery.should_not be_nil
    end

    it "formats the delivery_method" do
      @alert_delivery.formatted_delivery_method.should eq('SMS')
    end
  
    it "resolves with a reply" do
      @alert_delivery.resolve("I said so")
      @alert_delivery.reply.should eq("I said so")
    end
  end
  
  context 'being created' do
    before do
      @alert_delivery = AlertDelivery.create :alert => alerts(:typical_1), 
        :recipient => 'ab', :delivery_method => 'magic'
    end
    
    it "sets a slug" do
      @alert_delivery.slug.should_not be_nil
    end
  end      
end
