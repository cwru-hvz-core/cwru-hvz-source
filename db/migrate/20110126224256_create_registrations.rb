class CreateRegistrations < ActiveRecord::Migration
  def self.up
    create_table :registrations do |t|
      t.integer :person_id
      t.integer :game_id
      t.integer :faction_id
      t.string :card_code
      t.integer :score
      t.boolean :is_oz

      t.timestamps
    end
  end

  def self.down
    drop_table :registrations
  end
end
