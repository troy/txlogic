class AddProcessDefinitionsCustomerIdUsersCustomerId < ActiveRecord::Migration
  def self.up
    add_column :process_definitions, :customer_id, :integer
    add_column :users, :customer_id, :integer
    
    add_index :process_definitions, [ :launch_alias, :active ]
    add_index :process_definitions, [ :customer_id, :active ]
    
    add_index :silenced_recipients, [ :recipient, :delivery_method ]
  end

  def self.down
    remove_column :process_definitions, :customer_id
    remove_column :users, :customer_id
    
    remove_index :process_definitions, [ :launch_alias, :active ]
    remove_index :process_definitions, [ :customer_id, :active ]
    
    remove_index :silenced_recipients, [ :recipient, :delivery_method ]
  end
end
