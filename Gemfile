source "https://rubygems.org"

ruby "3.4.4"

gem "rails", "~> 8.0.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

# Weather API
gem "httparty"

group :development, :test do
  gem "debug", platforms: %i[ mri windows x64_mingw ]
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  # Testing gems
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "webmock"
  gem "vcr"
  gem "timecop"
end

group :development do
  gem "web-console"
end
