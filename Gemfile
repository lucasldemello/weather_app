source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.4"

gem "rails", "~> 8.0.2"
gem "pg", "~> 1.1"
gem "puma"
gem "sass-rails", ">= 6"
gem "webpacker", "~> 5.0"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder", "~> 2.7"
gem "bootsnap", ">= 1.4.4", require: false

# Weather API
gem "httparty"
gem "redis"

group :development, :test do
  gem "byebug", platforms: [ :mri, :mingw, :x64_mingw ]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "webmock"
  gem "vcr"
  gem "timecop"
end

group :development do
  gem "web-console", ">= 4.1.0"
  gem "listen", "~> 3.3"
  gem "spring"
end
