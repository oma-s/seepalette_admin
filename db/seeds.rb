# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

User.create_with(given_name: 'Admin', family_name: 'Test', password: 'password',
                  password_confirmation: 'password').find_or_create_by!(email: User::DEFAULT_EMAIL)

# Create 5 users
users = 5.times.map do |i|
  User.create!(
    email: "user#{i + 1}@example.com",
    given_name: Faker::Name.first_name,
    family_name: Faker::Name.last_name,
    password: 'password',
    password_confirmation: 'password'
  )
end

# For each user, create 20-30 working hours
users.each do |user|
  rand(20..30).times do
    # Random date between 2025-05-07 and today
    start_date = Faker::Date.between(from: Date.new(2025, 5, 7), to: Date.today)
    # Random start time between 10:00 and 16:00, rounded to nearest 30 min
    hour = rand(10..16)
    minute = [0, 30].sample
    start_at = Time.zone.local(start_date.year, start_date.month, start_date.day, hour, minute)

    # Duration: 4 to 9 hours
    duration_hours = rand(4..9)
    end_at = start_at + duration_hours.hours

    # Break logic
    break_minutes = if duration_hours >= 6
                      60
                    elsif duration_hours >= 3
                      30
                    else
                      0
                    end

    WorkingHour.create!(
      user: user,
      start_at: start_at,
      end_at: end_at,
      break_minutes: break_minutes
    )
  end
end
