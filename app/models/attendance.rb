class Attendance < ActiveRecord::Base
  belongs_to :registration
  belongs_to :mission

  validates_uniqueness_of :registration_id, :scope => :mission_id
  validates_presence_of :registration_id, :mission_id
end
