class Squad < ActiveRecord::Base
  has_many :registrations
  belongs_to :leader, :foreign_key => "leader_id", :class_name => "Registration"
  belongs_to :game

  validates_uniqueness_of :name, :scope => :game_id

  def points
    self.registrations.map{|x| x.display_score}.sum()
  end
end
