class Achievement < ActiveRecord::Base
  belongs_to :recipient, polymorphic: true
end
