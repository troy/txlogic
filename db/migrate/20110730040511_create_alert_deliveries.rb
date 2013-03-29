class CreateAlertDeliveries < ActiveRecord::Migration
  def self.up
    create_table :alert_deliveries do |t|
      t.integer :alert_id, :null => false
      t.string :workitem_id
      t.string :recipient, :null => false
      t.string :method, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :alert_deliveries
  end
end
