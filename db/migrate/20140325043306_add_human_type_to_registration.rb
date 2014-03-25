class AddHumanTypeToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :human_type, :string
  end
end
