require 'spec_helper'

describe ProcessDefinitionsController do
  include Devise::TestHelpers
  render_views
  
  describe "anonymously" do
    context "GET to :new" do
      it "responds" do
        get :new
        response.response_code.should eq(302)
      end
    end
  end
  
  describe "logged in" do
    before do
      request.env['warden'] = mock(Warden, :authenticate => users(:one),
                                           :authenticate! => users(:one))
    end
    
    describe "GET to :new" do
      it "responds" do
        get :new
        response.should be_success
      end
    end

    describe "POST to :create" do
      before do
        @basic_process = { 
           :name => 'tell someone who cares', 
           :time_zone => 'Central Time (US & Canada)',
           :process_markup => """
             process_definition do
               participant :recipient => '1111111111', :timeout => '2m'
             end
           """
         }
      end
     
      context "to save and verify" do
        it "responds" do
          post :create, :process_definition => @basic_process, :verify => '1'
          response.should be_redirect
          response.should redirect_to(edit_process_path(ProcessDefinition.find_by_name('tell someone who cares')))
        end

        it "saves" do
          expect {
            post :create, :process_definition => @basic_process, :verify => '1'
          }.to change(ProcessDefinition, :count).by(1)
        end
      end
    
      context "to save" do
        it "responds" do
          post :create, :process_definition => @basic_process
          response.should be_redirect
          response.should redirect_to(alerts_path)
        end

        it "saves" do
          expect {
            post :create, :process_definition => @basic_process
          }.to change(ProcessDefinition, :count).by(1)
        end
      
        it "is runnable" do
          post :create, :process_definition => @basic_process
          ProcessDefinition.find_by_name('tell someone who cares').should be
          ProcessDefinition.find_by_name('tell someone who cares').runnable_process.should be
        end
        
        it "sets the time_zone" do
          post :create, :process_definition => @basic_process
          ProcessDefinition.find_by_name('tell someone who cares').time_zone.should eq('Central Time (US & Canada)')
        end
      end
    
      context "with an invalid definition" do
        before do
          @broken_process = @basic_process
          @broken_process[:process_markup].sub!('process_definition', 'bogus')
        end
      
        it "doesn't save" do
          expect {
            post :create, :process_definition => @broken_process
          }.to change(ProcessDefinition, :count).by(0)
        end
      
        it "sets flash" do
          post :create, :process_definition => @broken_process
          flash[:error].should match(/isn't valid/)
        end
      end
    end

    describe "GET to :edit" do
      it "responds" do
        get :edit, :id => process_definitions(:typical).id
        response.should be_success
      end
    end
  
    describe "POST to :update" do
      it "responds" do
        post :update, :id => process_definitions(:typical).id, 
          :process_definition => @basic_process
        response.should be_redirect
      end
    end

    describe "GET to :invoke" do
      it "responds" do
        get :invoke, :id => process_definitions(:typical).id
        response.should be_success
      end
    end

    describe "POST to :pause" do
      it "responds" do
        post :pause, :id => process_definitions(:typical).id
        response.should be_redirect
      end
    end

    describe "POST to :resume" do
      it "responds" do
        post :resume, :id => process_definitions(:typical).id
        response.should be_redirect
      end
    end    

    describe "POST to :destroy" do
      it "responds" do
        expect {
          post :destroy, :id => process_definitions(:typical).id
        }.to change(ProcessDefinition, :count).by(-1)

        response.should be_redirect
      end
    end 
  end
end