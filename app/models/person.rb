class Person < ActiveRecord::Base
  has_many :infractions # Infractions submitted by this admin
  has_many :registrations
    has_many :waivers
  validates :caseid, :presence => true

  attr_accessible :name, :phone # The user-modifiable fields

  def phone=(arg)
    write_attribute(:phone, arg.gsub(/[^\d]/){|x| })
  end

  def ==(other)
    return false if self.nil? or other.nil?
    return false unless self.is_a?(Person) and other.is_a?(Person)
    self.caseid == other.caseid
  end

  def signed_waiver?(game)
    !!self.waivers.detect{ |w| w.game_id == game.id }
  end

  def can_change_name?
    return true if is_admin

    current_game = Game.current
    current_registration = registrations.where(:game_id => current_game.id).first

    return true if !current_registration.present?
    return false if current_game.has_begun?
  end

  def can_edit?(other)
    return true if is_admin

    self == other
  end

  def legal_to_sign_waiver?
    ((Date.today - date_of_birth).days / 1.year) >= 18
  end
end
