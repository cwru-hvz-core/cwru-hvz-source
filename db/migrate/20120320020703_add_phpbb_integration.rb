class AddPhpbbIntegration < ActiveRecord::Migration
  def self.up
    add_column :games, :phpbb_database_host, :string
    add_column :games, :phpbb_database_username, :string
    add_column :games, :phpbb_database_password, :string
    add_column :games, :phpbb_database, :string
    add_column :games, :phpbb_field_identification, :string
    add_column :games, :phpbb_human_group, :integer
    add_column :games, :phpbb_zombie_group, :integer
  end

  def self.down
    remove_column :games, :phpbb_database_host
    remove_column :games, :phpbb_database_username
    remove_column :games, :phpbb_database_password
    remove_column :games, :phpbb_database
    remove_column :games, :phpbb_field_identification
    remove_column :games, :phpbb_human_group
    remove_column :games, :phpbb_zombie_group
  end
end
