# frozen_string_literal: true

ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "asset_sync", "~> 2.11.0"
gem "aws-sdk-s3", "~> 1.61.2"
gem "bootsnap", "~> 1"
gem "fog-aws", "~> 3.6.2"
gem "govuk_app_config", "~> 2.1.1"
gem "govuk_publishing_components", "~> 21.41.1"
gem "lograge"
gem "pg", "~> 1"
gem "puma", "~> 4.3"
gem "rails", "~> 6.0.2"
gem "redis"
gem "sass-rails", "< 6"
gem "sentry-raven", "~> 3.0"
gem "uglifier", "~> 4.2"

group :development do
  gem "listen", "~> 3"
end

group :test do
  gem "apparition", "~> 0.5.0", require: false
  gem "capybara", "~> 3.32.1"
  gem "mini_racer", "~> 0.2"
  gem "selenium-webdriver"
  gem "simplecov", "~> 0.16"
  gem "webdrivers"
end

group :development, :test do
  gem "awesome_print", "~> 1.8"
  gem "better_errors", "~> 2.6"
  gem "binding_of_caller", "~> 0.8.0"
  gem "byebug", "~> 11"
  gem "foreman", "~> 0.87.1"
  gem "pry", "~> 0.13.1"
  gem "pry-rails", "~> 0.3.9"
  gem "rails-controller-testing", "~> 1.0"
  gem "rspec-rails", "~> 4.0.0"
  gem "rubocop-govuk"
  gem "scss_lint-govuk", "~> 0"
end
