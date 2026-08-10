# frozen_string_literal: true

FactoryBot.define do
  factory :work_shift do
    association :work_schedule_day_station
    association :user
    starts_at { work_schedule_day_station.work_schedule_day.date.in_time_zone.change(hour: 10) }
    ends_at { work_schedule_day_station.work_schedule_day.date.in_time_zone.change(hour: 18) }
    notes { nil }
  end
end
