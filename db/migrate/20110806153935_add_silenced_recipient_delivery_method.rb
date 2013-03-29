class AddSilencedRecipientDeliveryMethod < ActiveRecord::Migration
  def self.up
    add_column :silenced_recipients, :delivery_method, :string
  end

  def self.down
    remove_column :silenced_recipients, :delivery_method
  end
end
