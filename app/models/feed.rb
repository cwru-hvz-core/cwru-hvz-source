class Feed < ActiveRecord::Base
	belongs_to :registration
	belongs_to :tag
end
