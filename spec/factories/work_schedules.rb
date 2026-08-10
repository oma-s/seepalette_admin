# frozen_string_literal: true

FactoryBot.define do
  factory :work_schedule do
    sequence(:title) { |number| "Work schedule #{number}" }
    starts_on { Date.new(2026, 8, 7) }
    ends_on { Date.new(2026, 8, 9) }
    status { :draft }
    notes { nil }
  end
end
