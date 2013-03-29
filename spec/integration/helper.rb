require 'spec_helper'
require 'capybara/rspec'

support_file_paths = File.expand_path 'support/**/*.rb', File.dirname(__FILE__)
Dir[support_file_paths].each {|f| require f}
