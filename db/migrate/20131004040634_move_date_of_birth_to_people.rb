class MoveDateOfBirthToPeople < ActiveRecord::Migration
  def up
    change_table :people do |t|
      t.date :date_of_birth
    end

    Person.all.each do |p|
      dob = p.waivers.first.try(:dateofbirth)
      p.update_attribute(:date_of_birth, dob) if dob
    end

    remove_column :waivers, :dateofbirth
  end

  def down
    raise ActiveRecord::IrreversibleMigration
    # jk, it's reversible, I'm just too lazy to write the other direction
  end
end
