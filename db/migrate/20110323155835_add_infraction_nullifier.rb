class AddInfractionNullifier < ActiveRecord::Migration
  def self.up
	add_column :infractions,:nullified,:boolean,:default=>:false
  end

  def self.down
	remove_column :infractions,:nullified
  end
end
