FactoryGirl.define do
  factory :game do
    short_name 'Spring 2013'
    registration_begins { Time.now + 1.day }
    registration_ends   { Time.now + 3.days }
    game_begins         { Time.now + 3.days + 1.minute }
    oz_reveal           { Time.now + 4.days + 1.minute }
    game_ends           { Time.now + 13.days }
    rules 'There are no rules, have fun!'
    information 'This is the homepage!'
    time_zone 'Eastern Time (US & Canada)'

    factory :current_game do
      is_current true

      before(:create) do
        Game.where(is_current: true).destroy_all
      end
    end

    trait :begun do
      registration_begins { Time.now - 5.day }
      registration_ends   { Time.now - 3.days }
      game_begins         { Time.now - 3.days + 1.minute }
      oz_reveal           { Time.now - 2.days + 1.minute }
      game_ends           { Time.now + 7.days }
    end
  end
end
