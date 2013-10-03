FactoryGirl.define do
  factory :waiver do
    person
    game
    studentid 12345
    datesigned { Date.today - 3.days }
    dateofbirth { Date.today - 19.years }
    emergencyname 'Just call 911'
    emergencyrelationship '911'
    emergencyphone '123-456-7890'
  end
end
