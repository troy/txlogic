class AddAlertDeliveriesReply < ActiveRecord::Migration
  def self.up
    add_column :alert_deliveries, :reply, :string, :limit => 32
  end

  def self.down
    remove_column :alert_deliveries, :reply
  end
end
