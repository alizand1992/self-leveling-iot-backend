# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'jbuilder', '2.10.0'
gem 'puma', '4.3.5'
gem 'rails', '6.0.3'
gem 'sqlite3', '1.4.2'
gem 'webpacker', '5.1.1'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '6.1.0'
  gem 'pry', '0.13.1'
  gem 'rspec-rails', '~> 3.5'
  gem 'rubocop-rails', '2.7.0'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'webdrivers'
end

gem 'devise', '4.7.2'
gem 'devise-jwt', '0.8.0'

gem 'rack-cors', '1.1.1'
