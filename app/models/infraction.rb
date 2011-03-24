class Infraction < ActiveRecord::Base
	belongs_to :person, :foreign_key => "admin_id"
	belongs_to :registration, :foreign_key => "registration_id"
	validates_length_of :reason, :minimum=>1, :message=>"cannot be empty. Please include a detailed account of the infraction."
end
