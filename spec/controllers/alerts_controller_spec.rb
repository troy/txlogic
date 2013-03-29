require 'spec_helper'

describe AlertsController do
  include Devise::TestHelpers
  render_views
  
  describe "anonymously" do
    context "GET to :index" do
      it "responds" do
        get :index
        response.response_code.should eq(302)
      end
    end
  end

  describe "logged in" do
    before do
      request.env['warden'] = mock(Warden, :authenticate => users(:one),
                                           :authenticate! => users(:one))
    end
    
    describe "GET to :index" do
      it "responds" do
        get :index
        response.should be_success
      end
      
      it "displays the dashboard" do
        get :index
        response.body.should match(/Transmit Logic/)
      end
    end

    describe "GET to :index (JSON)" do
      it "responds" do
        get :index, :format => 'json'
        response.should be_success
      end
    end
    
    describe "GET to :show" do
      it "responds" do
        get :show, :id => alerts(:sms_1).id
        response.should be_success
      end
    end
    
    describe "invoking an alert" do
      before do
        participant_stubs
      end
      
      describe "POST to :create" do
        it "creates an Alert" do
          expect {
            post :create, :id => process_definitions(:typical).launch_alias,
              :subject => 'a'*500, :message => 'other test'
          }.to change(Alert, :count).by(1)
        end
        
        it "responds" do
          post :create, :id => process_definitions(:typical).launch_alias,
            :subject => 'test', :message => 'other test'          

          response.should be_success
        end
        
        it "serves nothing" do
          post :create, :id => process_definitions(:typical).launch_alias,
            :subject => 'test', :message => 'other test'          

          response.body.should eq(' ')
        end

        context "with an alert ID as a user Web submission" do
          it "creates an Alert" do
            expect {
              post :create, :alert => { :process_definition_id => process_definitions(:typical).id,
                :subject => 'test', :message => 'other test' }
            }.to change(Alert, :count).by(1)
          end
        end
      end
    end
    
    describe "resolving an alert" do
      context "that doesn't exist" do
        context "by stopping" do
          it "responds" do
            expect { 
              post :stop, :id => alerts(:sms_1).id
            }.to raise_error
          end
        end
      end

      context "that exists" do
        before do
          Alerter.any_instance.stub(:cancel_process).and_return(true)
        end

        context "by stopping" do
          it "responds" do
            post :stop, :id => alerts(:sms_1).id
            response.should be_redirect
          end
        end
        
        context "by accepting" do
          it "response" do
            post :accept, :id => alerts(:sms_1).id
            response.should be_redirect
          end
        end
      end
    end
  end
end
