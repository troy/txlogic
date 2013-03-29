class RenameProcessDefinitionsUuidLaunchAlias < ActiveRecord::Migration
  def self.up
    rename_column :process_definitions, :uuid, :launch_alias
  end

  def self.down
    rename_column :process_definitions, :launch_alias, :uuid
  end
end
