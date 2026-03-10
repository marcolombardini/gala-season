source 'https://rubygems.org'

gem 'bootsnap', require: false
gem 'image_processing', '~> 1.2'
gem 'pg'
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.1'
gem 'tzinfo-data', platforms: %i[windows jruby]

# Frontend
gem 'inertia_rails', '~> 3.17'
gem 'vite_rails', '~> 3.0'

# Background jobs
gem 'sidekiq', '~> 8.1'
gem 'sidekiq-scheduler', '~> 6.0'

# Redis
gem 'hiredis-client'
gem 'redis', '~> 5.0'
gem 'redis-actionpack', '~> 5.4'

group :development, :test do
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'dotenv-rails'
  gem 'minitest'
  gem 'mocha', '~> 3.0'
  gem 'vcr', '~> 6.3'
  gem 'webmock', '~> 3.24'
end

group :development do
  gem 'brakeman', '~> 8.0', require: false
  gem 'bundler-audit', require: false
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'web-console'
end
