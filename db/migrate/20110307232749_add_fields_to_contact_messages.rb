class AddFieldsToContactMessages < ActiveRecord::Migration
  def self.up
	  add_column :contact_messages, :game_id, :integer
	  add_column :contact_messages, :visible, :boolean, :default => true
  end

  def self.down
	  remove_column :contact_messages, :game_id
	  remove_column :contact_messages, :visible
  end
end
