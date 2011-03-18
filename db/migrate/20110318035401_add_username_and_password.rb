class AddUsernameAndPassword < ActiveRecord::Migration
  def self.up
	  add_column :games, :gv_username, :string
	  add_column :games, :gv_password, :string
  end

  def self.down
	  remove_column :games, :gv_username
	  remove_column :games, :gv_password
  end
end
