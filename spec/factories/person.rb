FactoryGirl.define do
  factory :person do
    name 'John Doe'
    caseid 'jxd123'
    phone '3305551234'
    is_admin false

    factory :admin do
      is_admin true
    end
  end
end
