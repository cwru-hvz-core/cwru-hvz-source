FactoryGirl.define do
  factory :tag do
    game
    association :tagger, factory: :registration
    association :tagee, factory: :registration
  end
end
