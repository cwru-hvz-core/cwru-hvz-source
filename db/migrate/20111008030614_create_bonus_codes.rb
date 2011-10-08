class CreateBonusCodes < ActiveRecord::Migration
  def self.up
    create_table :bonus_codes do |t|
      t.string :code
      t.integer :points
      t.integer :game_id
      t.integer :registration_id

      t.timestamps
    end
  end

  def self.down
    drop_table :bonus_codes
  end
end
