# frozen_string_literal: true

FactoryBot.define do
  factory :work_shift do
    association :work_schedule_day
    association :user
    position { "Bar" }
    starts_at { work_schedule_day.date.in_time_zone.change(hour: 10) }
    ends_at { work_schedule_day.date.in_time_zone.change(hour: 18) }
    break_minutes { 30 }
    notes { nil }
  end
end
