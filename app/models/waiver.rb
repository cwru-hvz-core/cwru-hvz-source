class Waiver < ActiveRecord::Base
  belongs_to :game
  belongs_to :person

  accepts_nested_attributes_for :person

  attr_accessor :signature, :chk1, :chk2, :chk3, :chk4
end
