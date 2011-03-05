class AddGameInformation < ActiveRecord::Migration
  def self.up
	  add_column :games, :information, :text, :default=>"No information given."
  end

  def self.down
	  remove_column :games, :information
  end
end
