class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.integer :process_definition_id
      t.string :subject
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
