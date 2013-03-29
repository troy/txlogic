class CreateSilencedRecipients < ActiveRecord::Migration
  def self.up
    create_table :silenced_recipients do |t|
      t.string :recipient, :null => false
      t.datetime :expires_at, :unll => false

      t.timestamps
    end
  end

  def self.down
    drop_table :silenced_recipients
  end
end
