class Customer < ActiveRecord::Base
  has_many :process_definitions, :dependent => :destroy
  has_many :alerts, :dependent => :destroy
  has_many :users, :dependent => :destroy
end
