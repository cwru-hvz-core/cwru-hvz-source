class Registration < ActiveRecord::Base
	belongs_to :person
	belongs_to :game
	has_many :infractions
	has_many :feeds
	has_many :attendances
	has_many :has_fed, :foreign_key => "feeder_id"
	has_many :tagged, :foreign_key => "tagger_id"
	has_many :taggedby, :foreign_key => "tagee_id"
end
