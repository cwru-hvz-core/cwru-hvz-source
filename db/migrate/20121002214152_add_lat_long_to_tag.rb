class AddLatLongToTag < ActiveRecord::Migration
  def self.up
    add_column :tags, :latitude, :decimal
    add_column :tags, :longitude, :decimal
  end

  def self.down
    remove_column :tags, :latitude
    remove_column :tags, :longitude
  end
end
