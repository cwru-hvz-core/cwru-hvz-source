class CreateSquads < ActiveRecord::Migration
  def self.up
    create_table :squads do |t|
      t.string :name
      t.integer :leader_id

      t.timestamps
    end

    add_column :registrations, :squad_id, :integer
  end

  def self.down
    drop_table :squads
    remove_column :registrations, :squad_id
  end
end
