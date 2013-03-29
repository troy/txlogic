require 'spec_helper'

describe 'a ProcessDefinition' do
  context "that is functional" do
    before do
      @process_definition = process_definitions(:typical)
    end
    
    it "has user-facing markup" do
      @process_definition.process_markup.should be
    end

    it "generates a runnable process" do
      @process_definition.runnable_process.class.should eq(Array)
    end
    
    context "being changed" do
      before do
        @process_definition.process_markup = """process_definition do
          participant 'sms troy', :recipient => '1111111111', :timeout => '2m'
        end"""
      end
      
      it "presents user-facing markup" do
        @process_definition.process_markup.should be
        @process_definition.process_markup.class.should eq(String)
        @process_definition.process_markup.should match(/^process_def/)        
      end
      
      it "presents ruote-facing definition" do
        @process_definition.definition.should match(/^Ruote.process_def/)
      end
      
      it "generates a runnable process" do
        @process_definition.runnable_process.class.should eq(Array)
      end
    end
  end
  
  context "that is evil" do
    before do
      @process_definition = process_definitions(:malicious)
    end
    
    it "raises an execution when run" do
      expect { process_definition.runnable_process }.to raise_error
    end
  end
  
  context "that is syntactically incorrect" do
    before do
      @process_definition = process_definitions(:brokenproc)
    end
    
    it "does not generate a runnable process" do
      expect { @process_definition.runnable_process }.
        to raise_error(ArgumentError)
    end
    
    it "is not valid" do
      @process_definition.should_not be_valid
    end
  end  
end

describe "ProcessDefinition fixtures" do
  describe ":sms" do
    it "is valid" do
      process_definitions(:sms).runnable_process.should eq(["define", {}, [["participant", {"timeout"=>"5m", "sms troy"=>nil, "recipient"=>"2067778888"}, []]]])
    end
  end
  
  describe ":email_then_sms" do
    it "is valid" do
      process_definitions(:email_then_sms).runnable_process.class.should eq(Array)
    end
  end
  
  describe ":incomplete_participant" do
    it "is valid" do
      process_definitions(:incomplete_participant).runnable_process.class.should eq(Array)
    end
  end
end
