class AddCurrentGame < ActiveRecord::Migration
  def self.up
	  add_column :games, :is_current, :boolean
  end

  def self.down
	  remove_column :games, :is_current
  end
end
