class AddIndiciesToForeignKeys < ActiveRecord::Migration
  def up
    add_index :attendances, :registration_id
    add_index :attendances, :mission_id

    add_index :bonus_codes, [:game_id, :code]

    add_index :check_ins, :registration_id

    add_index :contact_messages, [:game_id, :visible]

    add_index :feeds, :tag_id
    add_index :feeds, :mission_id

    add_index :games, :is_current

    add_index :infractions, :registration_id

    add_index :missions, :game_id

    add_index :people, :caseid
    add_index :people, :is_admin
    add_index :people, :name

    add_index :registrations, [:game_id, :person_id]
    add_index :registrations, [:game_id, :faction_id]
    add_index :registrations, :card_code

    add_index :squads, :game_id

    add_index :tags, :game_id
    add_index :tags, :tagger_id
    add_index :tags, :tagee_id

    add_index :waivers, [:person_id, :game_id]
  end

  def down
  end
end
