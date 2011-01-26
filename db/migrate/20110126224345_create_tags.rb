class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.integer :game_id
      t.integer :tagger_id
      t.integer :tagee_id
      t.integer :mission_id
      t.datetime :datetime
      t.integer :score

      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end
