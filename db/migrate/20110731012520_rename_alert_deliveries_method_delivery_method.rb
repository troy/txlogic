class RenameAlertDeliveriesMethodDeliveryMethod < ActiveRecord::Migration
  def self.up
    rename_column :alert_deliveries, :method, :delivery_method
  end

  def self.down
    rename_column :alert_deliveries, :delivery_method, :method
  end
end
