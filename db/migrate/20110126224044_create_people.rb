class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :name
      t.string :caseid
      t.binary :picture
      t.string :phone
      t.datetime :last_login
      t.boolean :is_admin

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
