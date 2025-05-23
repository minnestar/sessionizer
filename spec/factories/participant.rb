FactoryBot.define do

  factory :participant do
    sequence :name do |n|
      "person#{n}"
    end

    email { "#{name.gsub(/\s/, '_')}@example.com" }
    password { "seekret!" }

    factory :joe do
      email { "joe@example.com" }
      name { "Joe Schmoe" }
    end

    factory :luke do
      email { "look@recursion.org" }
      name { "Luke Francl" }
      bio { "the man with the master plan" }
    end
  end
end
