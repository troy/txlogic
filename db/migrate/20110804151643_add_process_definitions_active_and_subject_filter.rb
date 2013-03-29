class AddProcessDefinitionsActiveAndSubjectFilter < ActiveRecord::Migration
  def self.up
    add_column :process_definitions, :active, :boolean, :default => true, :null => false
    add_column :process_definitions, :subject_filter, :string
  end

  def self.down
    remove_column :process_definitions, :active
    remove_column :process_definitions, :subject_filter
  end
end
