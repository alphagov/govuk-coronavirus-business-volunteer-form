# frozen_string_literal: true

ruby File.read(".ruby-version").strip

source "https://rubygems.org"

gem "aws-sdk-s3", "~> 1.61.2"
gem "bootsnap", "~> 1"
gem "govuk_app_config", "~> 2.1.1"
gem "govuk_publishing_components", "~> 21.38.5"
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
  gem "capybara", "~> 2.13.0"
  gem "simplecov", "~> 0.16"
  gem "therubyracer", "~> 0.12"
end

group :development, :test do
  gem "awesome_print", "~> 1.8"
  gem "byebug", "~> 11"
  gem "foreman", "~> 0.87.1"
  gem "pry", "~> 0.13.0"
  gem "pry-rails", "~> 0.3.9"
  gem "rails-controller-testing", "~> 1.0"
  gem "rspec-rails", "~> 4.0.0"
  gem "rubocop-govuk"
  gem "scss_lint-govuk", "~> 0"
end
