class AddOzReveal < ActiveRecord::Migration
  def self.up
	  add_column :games, :oz_reveal, :datetime
  end

  def self.down
	  remove_column :games, :oz_reveal
  end
end
