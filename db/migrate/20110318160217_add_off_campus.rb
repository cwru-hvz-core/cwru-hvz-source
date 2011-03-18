class AddOffCampus < ActiveRecord::Migration
  def self.up
	  add_column :registrations, :is_off_campus, :boolean, :default => :false
  end

  def self.down
	  remove_column :registrations, :is_off_campus
  end
end
