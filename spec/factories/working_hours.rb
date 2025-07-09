FactoryBot.define do
  factory :working_hour do
    date { "2025-07-09" }
    start_at { "2025-07-09 17:30:41" }
    end_at { "2025-07-09 17:30:41" }
    break_minutes { 1 }
    duration_minutes { 1 }
    user { nil }
  end
end
