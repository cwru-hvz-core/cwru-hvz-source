FactoryGirl.define do
  factory :mission do
    game

    sequence(:start) { |b| game.game_begins + b.hours }
    sequence(:end) { |e| game.game_begins + e.hours }
    sequence(:title) { |n| "Push The Cart - Version #{n}" }
    storyline 'We must push zee cart!'
    description 'Here is the description part'
  end
end
