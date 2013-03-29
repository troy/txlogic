require 'integration/helper'

describe PagesController, type: :request do
  describe 'the home page' do
    before { visit path_to(:home) }

    it 'links to the sign in page' do
      click_link 'Sign In'
      current_path.should eq(path_to(:sign_in))
    end

    it 'shows the sign up form' do
      within 'form#mc-embedded-subscribe-form' do
        page.should have_selector('input[name=EMAIL]')
        page.should have_selector('input[type=submit][value="Send me early access"]')
      end
    end
  end
end
