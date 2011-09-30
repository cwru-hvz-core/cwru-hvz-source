class RemoveWaiverFromRegistration < ActiveRecord::Migration
  def self.up
    remove_column :registrations, :has_waiver
  end

  def self.down
    add_column :registrations, :has_waiver, :boolean
  end
end
