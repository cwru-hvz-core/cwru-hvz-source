class AddWaiverSupport < ActiveRecord::Migration
  def self.up
	  add_column :registrations, :has_waiver, :boolean, :default => :false
  end

  def self.down
	  remove_column :registrations, :has_waiver
  end
end
