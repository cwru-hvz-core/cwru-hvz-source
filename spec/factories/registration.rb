FactoryGirl.define do
  factory :registration do
    game
    person

    faction_id nil
    sequence(:card_code) { |c| "ABC#{c}" }
    score 1200
    is_oz false
    wants_oz false
    is_off_campus false

    factory :human do
      faction_id 0
    end

    factory :zombie do
      faction_id 1
    end
  end
end
