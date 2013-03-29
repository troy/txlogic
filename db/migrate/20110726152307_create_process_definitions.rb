class CreateProcessDefinitions < ActiveRecord::Migration
  def self.up
    create_table :process_definitions do |t|
      t.string :name
      t.string :uuid, :limit => 37
      t.text :definition

      t.timestamps
    end
  end

  def self.down
    drop_table :process_definitions
  end
end
