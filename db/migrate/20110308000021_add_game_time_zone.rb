class AddGameTimeZone < ActiveRecord::Migration
  def self.up
	  add_column :games, :time_zone, :string, :default => "Eastern Time (US & Canada)"
  end

  def self.down
	  remove_column :games, :time_zone
  end
end
