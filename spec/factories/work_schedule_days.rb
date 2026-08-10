# frozen_string_literal: true

FactoryBot.define do
  factory :work_schedule_day do
    association :work_schedule
    date { work_schedule.starts_on }
    title { nil }
    notes { nil }
  end
end
