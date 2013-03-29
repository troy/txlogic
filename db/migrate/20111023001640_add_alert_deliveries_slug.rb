class AddAlertDeliveriesSlug < ActiveRecord::Migration
  def self.up
    add_column :alert_deliveries, :slug, :string, :limit => 32
    add_index :alert_deliveries, :slug
  end

  def self.down
    remove_column :alert_deliveries, :slug
  end
end
