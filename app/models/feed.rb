class Feed < ActiveRecord::Base
	belongs_to :registration
	belongs_to :registration, :foreign_key => "feeder_id"
end
