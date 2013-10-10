FactoryGirl.define do
  factory :tag do
    game
    association :tagger, factory: :registration
    association :tagee, factory: :registration
    datetime { game.game_begins + 1.hour }
  end
end
