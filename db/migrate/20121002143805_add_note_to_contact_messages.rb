class AddNoteToContactMessages < ActiveRecord::Migration
  def self.up
    add_column :contact_messages, :note, :text
  end

  def self.down
    remove_column :contact_messages, :note
  end
end
