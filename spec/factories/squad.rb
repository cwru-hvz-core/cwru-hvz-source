FactoryGirl.define do
  factory :squad do
    game

    name 'The Dooner Party'
    association :leader, :factory => :registration
  end
end
