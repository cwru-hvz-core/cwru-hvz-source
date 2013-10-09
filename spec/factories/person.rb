FactoryGirl.define do
  factory :person do
    name { |n| 'John #{n} Doe' }
    sequence(:caseid) { |n| "jxd12#{n}" }
    phone '3305551234'
    is_admin false
    date_of_birth { Date.today - 19.years }

    factory :admin do
      is_admin true
    end

    trait :underage do
      date_of_birth { Date.today - 17.years }
    end
  end
end
