# frozen_string_literal: true

FactoryBot.define do
  factory :day_notice do
    association :work_schedule_day
    text { "Techniker kommt vorbei" }
    severity { "info" }
  end
end
