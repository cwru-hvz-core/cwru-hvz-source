class CreateInfractions < ActiveRecord::Migration
  def self.up
    create_table :infractions do |t|
      t.integer :registration_id
      t.text :reason
      t.integer :admin_id
      t.integer :severity

      t.timestamps
    end
  end

  def self.down
    drop_table :infractions
  end
end
