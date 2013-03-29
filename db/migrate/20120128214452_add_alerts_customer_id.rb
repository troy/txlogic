class AddAlertsCustomerId < ActiveRecord::Migration
  def self.up
    add_column :alerts, :customer_id, :integer
  end

  def self.down
    remove_column :alerts, :customer_id
  end
end
