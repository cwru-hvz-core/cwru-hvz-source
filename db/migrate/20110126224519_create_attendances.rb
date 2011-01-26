class CreateAttendances < ActiveRecord::Migration
  def self.up
    create_table :attendances do |t|
      t.integer :registration_id
      t.integer :mission_id
      t.integer :score

      t.timestamps
    end
  end

  def self.down
    drop_table :attendances
  end
end
