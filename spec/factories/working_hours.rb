FactoryBot.define do
  factory :working_hour do
    association :user
    date { 2.days.ago.to_date }
    start_at { date.in_time_zone.change(hour: 9) }
    end_at { date.in_time_zone.change(hour: 17) }
    break_minutes { 30 }
  end
end
