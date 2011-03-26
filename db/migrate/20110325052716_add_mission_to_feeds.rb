class AddMissionToFeeds < ActiveRecord::Migration
  def self.up
	  add_column :feeds, :mission_id, :integer
  end

  def self.down
	  remove_column :feeds, :mission_id
  end
end
