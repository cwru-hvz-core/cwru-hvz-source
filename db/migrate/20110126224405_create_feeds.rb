class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.integer :registration_id
      t.datetime :datetime
      t.integer :feeder_id

      t.timestamps
    end
  end

  def self.down
    drop_table :feeds
  end
end
