class AddAlertsResolver < ActiveRecord::Migration
  def self.up
    add_column :alerts, :resolver, :string
  end

  def self.down
    remove_column :alerts, :resolver
  end
end
