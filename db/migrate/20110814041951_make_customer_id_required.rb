class MakeCustomerIdRequired < ActiveRecord::Migration
  def self.up
    change_column :users, :customer_id, :integer, :null => false
    change_column :process_definitions, :customer_id, :integer, :null => false    
  end

  def self.down
    change_column :users, :customer_id, :integer
    change_column :process_definitions, :customer_id, :integer
  end
end
