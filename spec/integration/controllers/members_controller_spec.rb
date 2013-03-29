require 'integration/helper'

describe MembersController, type: :request do
  let(:me)     { users :confirmed }
  let(:member) { users :one }

  describe 'viewing members' do
    context 'when signed in' do
      before do
        sign_in_with_email me.email
        visit path_to(:members)
      end

      it 'shows all members' do
        Dom::Member.find_by_email(me.email).should be
        Dom::Member.find_by_email(member.email).should be
      end
    end

    context 'when signed out' do
      before { visit path_to(:members) }

      it 'redirects to the sign in page' do
        current_path.should eq(path_to(:sign_in))
      end
    end
  end

  describe 'inviting a member' do
    let(:email) { 'ford@prefect.com' }

    before do
      sign_in_with_email me.email
      visit path_to(:members)

      within '#new_user' do
        fill_in 'Email address', with: email
        click_button 'Invite'
      end
    end

    it 'redirects to the members list' do
      current_path.should eq(path_to(:members))
    end

    it 'creates a new member' do
      User.exists?(email: email).should be
    end

    it 'invites the new member' do
      delivered_email = ActionMailer::Base.deliveries.last

      delivered_email.to.should include(email)
      delivered_email.subject.should include("invitation")
      delivered_email.body.raw_source.should include("been invited to")
    end
  end

  describe '#destroy' do
    let(:email) { 'a@b.com' }

    before do
      sign_in_with_email me.email
      visit path_to(:members)

      within "table tr:contains(#{ member.email.inspect })" do
        click_link 'Remove'
      end
    end

    it 'redirects to the members list' do
      current_path.should eq(path_to(:members))
    end

    it 'removes the member' do
      User.exists?(email: member.email).should_not be
    end
  end
end
