class DefaultAdminToFalse < ActiveRecord::Migration
  def self.up
	  change_column :people, :is_admin, :boolean, :default => false
  end

  def self.down
  end
end
