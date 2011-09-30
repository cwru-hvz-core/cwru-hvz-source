class CreateWaivers < ActiveRecord::Migration
  def self.up
    create_table :waivers do |t|
      t.integer :person_id
      t.integer :game_id
      t.integer :studentid
      t.date :datesigned
      t.date :dateofbirth
      t.string :emergencyname
      t.string :emergencyrelationship
      t.string :emergencyphone

      t.timestamps
    end
  end

  def self.down
    drop_table :waivers
  end
end
