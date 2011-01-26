class Tag < ActiveRecord::Base
	belongs_to :registration, :foreign_key => "tagger_id"
	belongs_to :registration, :foreign_key => "tagee_id"
	belongs_to :game
end
