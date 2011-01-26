class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.string :short_name
      t.datetime :registration_begins
      t.datetime :registration_ends
      t.datetime :game_begins
      t.datetime :game_ends

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
