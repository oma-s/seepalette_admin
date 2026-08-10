FactoryBot.define do
  factory :user do
    given_name { 'Test' }
    family_name { 'User' }
    sequence(:email) { |number| "user-#{number}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
