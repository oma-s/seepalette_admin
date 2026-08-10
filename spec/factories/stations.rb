# frozen_string_literal: true

FactoryBot.define do
  factory :station do
    sequence(:name) { |number| "Station #{number}" }
    sequence(:position)
    active { true }
    default_enabled { false }
  end
end
