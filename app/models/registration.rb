class Registration < ActiveRecord::Base
	belongs_to :person
	belongs_to :game
	has_many :infractions
	has_many :feeds
	has_many :attendances
	has_many :has_fed, :foreign_key => "feeder_id"
	has_many :tagged, :foreign_key => "tagger_id", :class_name => "Tag"
	has_many :taggedby, :foreign_key => "tagee_id", :class_name => "Tag"

	validates_uniqueness_of :person_id, :scope => :game_id
	validates_presence_of :person_id, :game_id, :card_code

	def self.make_code
		chars = %w{ A B C D E F 1 2 3 4 5 6 7 8 9 }
		(0..5).map{ chars.to_a[rand(chars.size)] }.join
	end
end
