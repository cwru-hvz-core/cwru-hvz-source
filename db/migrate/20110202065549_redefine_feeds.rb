class RedefineFeeds < ActiveRecord::Migration
  def self.up
	  remove_column :feeds, :feeder_id
	  add_column :feeds, :tag_id, :integer
  end

  def self.down
	raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted columns"	    
  end
end
