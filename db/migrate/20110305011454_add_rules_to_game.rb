class AddRulesToGame < ActiveRecord::Migration
  def self.up
	  add_column :games, :rules, :text, :default => "No rules have been posted yet. Check back later!"
  end

  def self.down
	  remove_column :games, :rules
  end
end
