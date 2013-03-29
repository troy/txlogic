require 'isolated/helper'
require 'support/controller'

stub_class :ApplicationController do
  def self.skip_before_filter(*args); end
end
stub_classes :Alert, :AlertDelivery

require 'alert_deliveries_controller'

describe AlertDeliveriesController, :controller do
  describe '#show' do
    let(:alert_delivery)    { stub }
    let(:alert_delivery_id) { 42 }
    let(:alert)    { stub }
    let(:alert_id) { 1 }
    let(:new_user_session_path) { '/sign_in' }
    let(:params) {{ id: alert_delivery_id }}

    before do
      AlertDelivery.stub find_by_slug: alert_delivery
      alert_delivery.stub accessible_anonymously?: true
      subject.stub new_user_session_path: new_user_session_path,
                   redirect_to: nil, user_signed_in?: true
    end

    context 'an alert accessible anonymously' do
      before do
        Alert.stub_chain(:includes, :find) { alert }
        alert_delivery.stub alert_id: alert_id
        subject.stub render: nil
      end

      it 'finds the alert delivery' do
        AlertDelivery.should_receive(:find_by_slug).
                      with(alert_delivery_id).
                      and_return(alert_delivery)

        call_action :show, params
      end

      it 'finds the alert' do
        with_deliveries = stub :with_deliveries
        with_deliveries.should_receive(:find).
                        with(alert_id).
                        and_return(alert)

        Alert.should_receive(:includes).
              with(:deliveries).
              and_return(with_deliveries)

        call_action :show
      end

      it 'renders the alert page' do
        subject.should_receive(:render).with(template: 'alerts/show')
        call_action :show
      end

      context 'authenticated' do
        before { subject.stub user_signed_in?: true }

        it 'has no flash message' do
          call_action :show
          flash[:notice].should_not be
        end
      end

      context 'anonymous' do
        before { subject.stub user_signed_in?: false }

        it 'has a flash message' do
          call_action :show
          flash[:notice].should eq('Login to respond to this alert.')
        end
      end
    end

    context 'an alert not accessible anonymously' do
      let(:current_customer) { stub }

      before do
        alert_delivery.stub accessible_anonymously?: false
      end

      context 'authenticated' do
        before do
          alert_delivery.stub alert_id: alert_id
          current_customer.stub_chain(:alerts, :includes, :find) { alert }
          subject.stub current_customer: current_customer, render: nil
        end

        it 'finds the alert' do
          with_deliveries = stub :with_deliveries
          with_deliveries.should_receive(:find).
                          with(alert_id).
                          and_return(alert)

          with_alerts = stub :with_alerts
          with_alerts.should_receive(:includes).
                      with(:deliveries).
                      and_return(with_deliveries)

          current_customer.should_receive(:alerts).and_return(with_alerts)

          call_action :show
        end

        it 'renders the alert page' do
          subject.should_receive(:render).with(template: 'alerts/show')
          call_action :show
        end

        it 'has no flash message' do
          call_action :show
          flash[:notice].should_not be
        end
      end

      context 'anonymous' do
        before { subject.stub user_signed_in?: false }

        it 'redirects to the sign in page' do
          subject.should_receive(:redirect_to).with(new_user_session_path)
          call_action :show
        end
      end
    end
  end
end
