class AddSquadsToGames < ActiveRecord::Migration
  def self.up
    add_column :squads, :game_id, :integer
  end

  def self.down
    remove_column :squads, :game_id
  end
end
