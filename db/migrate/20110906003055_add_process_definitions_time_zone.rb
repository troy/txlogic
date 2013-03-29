class AddProcessDefinitionsTimeZone < ActiveRecord::Migration
  def self.up
    add_column :process_definitions, :time_zone, :string
  end

  def self.down
    remove_column :process_definitions, :time_zone
  end
end
