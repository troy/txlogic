require 'isolated/helper'
require 'support/controller'

stub_class :ApplicationController do
  def self.layout(*args);             end
  def self.skip_before_filter(*args); end
end

require 'pages_controller'

describe PagesController, :controller do
  describe '#index' do
    let(:alerts_path) { '/alerts' }
    before { subject.stub! user_signed_in?: false }

    it 'shows the home page' do
      call_action :index
    end

    it 'redirects to the alerts page when authenticated' do
      subject.stub! user_signed_in?: true, alerts_path: alerts_path
      subject.should_receive(:redirect_to).with(alerts_path)

      call_action :index
    end
  end
end
