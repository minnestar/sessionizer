FactoryGirl.define do

  factory :participant do
    sequence :name do |n|
      "person#{n}"
    end

    email { "#{name.gsub(/\s/, '_')}@example.com" }
    password 'seekret!'

    factory :joe do
      email "joe@example.com"
      name "Joe Schmoe"
    end

    factory :luke do
      email "look@recursion.org"
      name 'Luke Francl'
      github_profile_username "look"
      github_og_image "https://avatars1.githubusercontent.com/u/10186?v=3&s=400"
      github_og_url   "https://github.com/look"
      twitter_handle  "lof"
      bio 'the man with the master plan'
    end
  end
end
