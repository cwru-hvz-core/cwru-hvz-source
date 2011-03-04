class AddWantsOz < ActiveRecord::Migration
  def self.up
	  add_column :registrations, :wants_oz, :boolean, :default => false
	  change_column :registrations, :is_oz, :boolean, :default => false
  end

  def self.down
	  remove_column :registrations, :wants_oz
  end
end
