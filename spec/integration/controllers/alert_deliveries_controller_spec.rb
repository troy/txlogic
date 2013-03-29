require 'integration/helper'

describe AlertDeliveriesController, type: :request do
  def view_alert
    visit path_to(:alert_delivery, slug: alert_slug)
  end

  let(:alert_slug) { alert_delivery.slug }
  let(:title)      { alert_delivery.alert.subject }

  describe 'viewing a fresh alert' do
    let(:alert_delivery) { alert_deliveries :sms_delivery_2 }

    before { view_alert }

    it 'is visible without authentication' do
      Dom::Alert.find_by_title(title).should be
    end
  end

  describe 'viewing a stale alert' do
    let(:alert_delivery) { alert_deliveries :stale }

    context 'when signed out' do
      before { view_alert }

      it 'redirects to the sign in form' do
        current_path.should eq(path_to(:sign_in))
        Dom::Alert.find_by_title(title).should_not be
      end
    end

    context 'when signed in' do
      let(:me) { users :confirmed }

      before do
        sign_in_with_email me.email
        view_alert
      end

      it 'is visible' do
        Dom::Alert.find_by_title(title).should be
      end
    end
  end
end
