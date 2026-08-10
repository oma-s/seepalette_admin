# frozen_string_literal: true

FactoryBot.define do
  factory :work_schedule_day do
    association :work_schedule
    date { work_schedule.starts_on }
    grid_start_minute { 420 }
    grid_end_minute { 1_440 }

    initialize_with { work_schedule.work_schedule_days.find_or_initialize_by(date: date) }
  end
end
