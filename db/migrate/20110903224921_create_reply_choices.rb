class CreateReplyChoices < ActiveRecord::Migration
  def self.up
    create_table :reply_choices do |t|
      t.integer :alert_delivery_id, :null => false
      t.string :reply, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :reply_choices
  end
end
