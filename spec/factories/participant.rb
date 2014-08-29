FactoryGirl.define do

  factory :participant do
    password 'sekret'

    factory :joe do
      email "joe@example.com"
      name "Joe Schmoe"
    end

    factory :luke do
      email "look@recursion.org"
      name 'Luke Francl'
    end
  end
end
