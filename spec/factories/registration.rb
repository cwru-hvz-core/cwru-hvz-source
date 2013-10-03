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

    trait :human do
      faction_id 0
    end

    trait :zombie do
      faction_id 1

      after(:create) do |registration|
        registration.taggedby << FactoryGirl.create(:tag,
                                    tagee: registration,
                                    game: registration.game,
                                    datetime: 2.hours.ago) # XXX: incubation
      end
    end

    trait :deceased do
      faction_id 2

      after(:create) do |registration|
        registration.taggedby << FactoryGirl.create(:tag,
                                    tagee: registration,
                                    game: registration.game,
                                    datetime: 24.hours.ago)
      end
    end

    trait :oz do
      is_oz true
    end
  end
end
