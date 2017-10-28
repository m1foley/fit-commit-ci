source "https://rubygems.org"

gem "rails", "= 5.1.4"
gem "turbolinks"
gem "puma"
gem "pg", "~> 0.20"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.2", require: false

# views & stylesheets
gem "haml-rails"
gem "sass-rails"
gem "bourbon", ">= 5.0.0.beta.8"
gem "neat", "~> 1.9"
gem "rails-assets-normalize-css", source: "https://rails-assets.org"

# GitHub API
gem "octokit", "~> 4.7"
gem "omniauth-github"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
  gem "rubocop", "~> 0.49", require: false
end

group :test do
  gem "mocha"
  gem "webmock"
end
