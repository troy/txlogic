require 'isolated/helper'
require 'support/controller'

stub_classes :ApplicationController
stub_class(:User) { User::INVITATION_CODE = 'code' }

require 'members_controller'

describe MembersController, :controller do
  let(:current_customer) { stub :customer, users: members }
  let(:members) { stub :members }
  before { subject.stub current_customer: current_customer, respond_to: nil }

  describe '#index' do
    let(:members) { stub :members, all: nil, build: nil }

    it 'lists all members' do
      current_customer.should_receive(:users).and_return(members)
      members.should_receive(:all)

      call_action :index
    end

    it 'prepares a new member' do
      current_customer.should_receive(:users).and_return(members)
      members.should_receive(:build)

      call_action :index
    end
  end

  describe '#create' do
    let(:members)  { stub :members, build: new_member }
    let(:email)    { stub :email }
    let(:password) { stub :password }
    let(:params)   {{ user: { email: email }}}
    let(:new_member) do
      stub :new_member, :confirmed_at= => nil,
                        save: true,
                        send_member_invitation: true
    end

    before do
      SecureRandom.stub hex: password
    end

    it 'creates a random password' do
      SecureRandom.should_receive(:hex).with(8)
      call_action :create, params
    end

    it 'builds the new member' do
      attributes = { email:    email,
                     password: password,
                     password_confirmation: password,
                     invitation_code:       'code' }
      members.should_receive(:build).with(attributes)
      call_action :create, params
    end

    it "confirms the new member's account" do
      now = Time.now
      Time.stub now: now
      new_member.should_receive(:confirmed_at=).with(now)
      call_action :create, params
    end

    it 'saves the new member' do
      new_member.should_receive(:save)
      call_action :create, params
    end

    it 'sends the new member an invitation' do
      new_member.should_receive(:send_member_invitation)
      call_action :create, params
    end

    it 'shows a confirmation message' do
      call_action :create, params
      flash[:info].should eq('Invitation email sent.')
    end

    describe 'error saving the new member' do
      before { new_member.stub save: false }

      it 'does not send an invitation to the member 'do
        new_member.should_not_receive(:send_member_invitation)
        call_action :create, params
      end

      it 'shows an error message' do
        call_action :create, params
        flash[:error].should eq('Sorry, an error occurred.')
      end
    end

    describe 'error sending invitation' do
      before { new_member.stub send_member_invitation: false }

      it 'shows an error message' do
        call_action :create, params
        flash[:error].should eq('Sorry, an error occurred.')
      end
    end
  end

  describe '#destroy' do
    let(:member) { stub :member, destroy: true }
    let(:id)     { stub :id }
    let(:params) {{ id: id }}
    let(:authenticated_user) { stub :authenticated_user }

    before do
      members.stub find: member
      subject.stub current_user: authenticated_user
    end

    describe 'removing a member' do
      it 'finds the member' do
        members.should_receive(:find).with(id)
        call_action :destroy, params
      end

      it 'removes the member' do
        member.should_receive(:destroy)
        call_action :destroy, params
      end

      it 'shows a confirmation message' do
        call_action :destroy, params
        flash[:info].should eq('User removed.')
      end
    end

    describe 'removing the authenticated user' do
      before { subject.stub current_user: member }

      it "can't remove the member" do
        member.should_not_receive(:destroy)
        call_action :destroy, params
      end

      it "shows an error message" do
        call_action :destroy, params
        flash[:error].should eq("Can't delete yourself, even on a bad day.")
      end
    end

    describe 'error removing the member' do
      let(:member) { stub :member, destroy: false }

      it "shows an error message" do
        call_action :destroy, params
        flash[:error].should eq('Sorry, an error occurred.')
      end
    end
  end
end
