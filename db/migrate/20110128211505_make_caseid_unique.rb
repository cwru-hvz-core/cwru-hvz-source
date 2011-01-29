class MakeCaseidUnique < ActiveRecord::Migration
  def self.up
	  change_column :people, :caseid, :string, :unique => true
  end

  def self.down
	  change_column :people, :caseid, :string, :unique => false
  end
end
