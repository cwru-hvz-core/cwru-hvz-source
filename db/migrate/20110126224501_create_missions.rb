class CreateMissions < ActiveRecord::Migration
  def self.up
    create_table :missions do |t|
      t.integer :game_id
      t.datetime :start
      t.datetime :end
      t.text :description
      t.integer :winning_faction_id

      t.timestamps
    end
  end

  def self.down
    drop_table :missions
  end
end
