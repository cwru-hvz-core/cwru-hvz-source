class Attendance < ActiveRecord::Base
	belongs_to :registration
	belongs_to :mission
end
