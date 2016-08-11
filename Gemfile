source 'https://rubygems.org'

# Specification ruby and rails version
ruby '2.2.1'
gem 'rails', '3.2.13'

# For Heroku, more info at the following link
# https://devcenter.heroku.com/articles/ruby-support#injected-plugins
gem 'rails_12factor'

# Non-dynamic sorting and pagination
gem 'will_paginate', '~> 3.0'

# PostgreSQL
gem 'pg', '>=0.17.1'

# Libcurl bindings for Ruby
gem 'curb', '>=0.8.8'

# HTML, XML, SAX and Reader parser
gem 'nokogiri', '>=1.6.1'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'bootstrap-sass', '~> 3.3.5'
  gem 'autoprefixer-rails'
  gem 'sass-rails',     '~> 3.2.3'
  gem 'coffee-rails',   '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  # Automatically add model description to to the model.rb
  gem 'annotate'
  
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  
  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'
  
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
