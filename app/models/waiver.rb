class Waiver < ActiveRecord::Base
  belongs_to :game
  belongs_to :person

  attr_accessor :signature

  validate :check_signature
  validates_presence_of :emergencyname, :emergencyphone, :studentid

private

  def check_signature
    return unless new_record?

    return if signature.try(:downcase) == person.name.downcase

    errors.add(:signature, 'must match your name as it appears at the top')
  end
end
