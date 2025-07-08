# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.3'

gem 'puma'
gem 'rails', '~> 8.0.2'

# Use sqlite3 for development and test environments
group :development, :test do
  gem 'sqlite3'
end

# Use PostgreSQL for production
group :production do
  gem 'pg'
end

gem 'cssbundling-rails'
gem 'importmap-rails'
gem 'sprockets-rails'

gem 'activeadmin', '4.0.0.beta15' # github: "activeadmin/activeadmin", branch: "master"
gem 'devise'
gem 'pundit'
gem 'rolify'

gem 'slim-rails'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'database_cleaner-active_record'
  gem 'debug', platforms: %i[mri windows]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'
end

group :development do
  gem 'annotate'
  gem 'letter_opener'
  gem 'letter_opener_web'
end
