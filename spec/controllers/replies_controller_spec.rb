require 'spec_helper'

describe RepliesController do
  include Devise::TestHelpers
  render_views

  describe "POST to tropo" do
    context "with a silence request" do
      it "responds" do
        post :tropo, :sender  => '+12066831234',
                     :reply   => 'silence 5m',
                     :network => 'SMS'
        response.should be_success
      end

      it "saves SilenceRecipients for SMS and call" do
        expect {
          post :tropo, :sender  => '+12066831234',
                       :reply   => 'silence 5m',
                       :network => 'SMS'
        }.to change(SilencedRecipient, :count).by(2)
      end
    end
  end

  describe "POST to mailgun" do
    context "with a silence request" do
      it "responds" do
        post :mailgun, :recipient   => 'update-123@blah',
                       :sender      => 'bob@jones.com',
                       'body-plain' => 'silence 5m'
        response.should be_success
      end

      it "saves SilenceRecipients for SMS and call" do
        expect {
          post :mailgun, :recipient   => 'update-123@blah',
                         :sender      => 'bob@jones.com',
                         'body-plain' => 'silence 5m'
        }.to change(SilencedRecipient, :count).by(1)
      end
    end
  end
end
