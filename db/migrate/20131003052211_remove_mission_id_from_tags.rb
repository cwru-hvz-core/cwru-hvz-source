class RemoveMissionIdFromTags < ActiveRecord::Migration
  def up
    remove_column :tags, :mission_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
