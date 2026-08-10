# frozen_string_literal: true

FactoryBot.define do
  factory :work_schedule_day_station do
    work_schedule_day { create(:work_schedule).work_schedule_days.first }
    association :station
    name { station.name }
    position { station.position }
  end
end
