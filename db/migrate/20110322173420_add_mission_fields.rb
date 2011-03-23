class AddMissionFields < ActiveRecord::Migration
  def self.up
	  add_column :missions, :title, :string
	  add_column :missions, :storyline, :text
  end

  def self.down
	  remove_column :missions, :title
	  remove_column :missions, :storyline
  end
end
