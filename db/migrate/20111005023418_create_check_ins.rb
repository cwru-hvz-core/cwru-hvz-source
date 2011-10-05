class CreateCheckIns < ActiveRecord::Migration
  def self.up
    create_table :check_ins do |t|
      t.integer :registration_id
      t.string :hostname

      t.timestamps
    end
  end

  def self.down
    drop_table :check_ins
  end
end
