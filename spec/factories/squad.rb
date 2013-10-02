FactoryGirl.define do
  factory :squad do
    game
    registrations { FactoryGirl.build_list(:registration, 10, game: game) }

    name 'The Dooner Party'
    association :leader, :factory => :registration
  end
end
