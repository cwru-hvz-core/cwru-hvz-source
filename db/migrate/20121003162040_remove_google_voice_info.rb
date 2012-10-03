class RemoveGoogleVoiceInfo < ActiveRecord::Migration
  def self.up
    remove_column :games, :gv_username
    remove_column :games, :gv_password
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
