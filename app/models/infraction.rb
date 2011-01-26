class Infraction < ActiveRecord::Base
	belongs_to :person, :foreign_key => "admin_id"
	belongs_to :registration
end
