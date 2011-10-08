class BonusCode < ActiveRecord::Base
  belongs_to :registration
  belongs_to :game

  validates_uniqueness_of :code, :scope => [:game_id]

  attr_accessor :person_name, :person_id

  def person_name
    unless self.registration.nil?
      return self.registration.person.name
    end
  end
end
