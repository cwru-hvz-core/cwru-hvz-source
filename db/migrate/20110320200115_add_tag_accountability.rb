class AddTagAccountability < ActiveRecord::Migration
  def self.up
	  add_column :tags, :admin_id, :integer
  end

  def self.down
	  remove_column :tags, :admin_id
  end
end
