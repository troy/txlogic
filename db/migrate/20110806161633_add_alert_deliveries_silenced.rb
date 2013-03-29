class AddAlertDeliveriesSilenced < ActiveRecord::Migration
  def self.up
    add_column :alert_deliveries, :silenced, :boolean, :default => false
  end

  def self.down
    remove_column :alert_deliveries, :silenced
  end
end
