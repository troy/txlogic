class AddAlertsResolutionAndBy < ActiveRecord::Migration
  def self.up
    add_column :alerts, :resolution, :string, :limit => 64
    add_column :alerts, :by, :string, :limit => 64
  end

  def self.down
    remove_column :alerts, :resolution
    remove_column :alerts, :by
  end
end
