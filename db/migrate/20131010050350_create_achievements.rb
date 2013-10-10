class CreateAchievements < ActiveRecord::Migration
  def up
    create_table :achievements do |t|
      t.integer :recipient_id, null: false
      t.string :recipient_type, null: false
      t.string :type, null: false
      t.integer :points, default: 0

      t.datetime :created_at
    end
  end

  def down
    drop_table :achievements
  end
end
