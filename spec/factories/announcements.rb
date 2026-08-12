# frozen_string_literal: true

FactoryBot.define do
  factory :announcement do
    sequence(:title) { |number| "Hinweis #{number}" }
    body { "Wichtige Information für das Team." }
    severity { "info" }
    active { true }
    priority { 0 }
  end
end
