class Tag < ActiveRecord::Base
	has_many :registrations, :foreign_key => "tagger_id"
	has_many :registrations, :foreign_key => "tagee_id"
end
