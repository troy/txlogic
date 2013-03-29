class ChangeAlertsByResolvedById < ActiveRecord::Migration
  def self.up
    remove_column :alerts, :by
    add_column :alerts, :resolved_by_id, :integer
    
  end

  def self.down
    add_column :alerts, :by, :string
    remove_column :alerts, :resolved_by_id, :integer
  end
end
