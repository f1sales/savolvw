source "https://rubygems.org"

# Specify your gem's dependencies in savolvw.gemspec
gem 'f1sales_custom-email', github: 'marciok/f1sales_custom-email', branch: 'master'
gem 'f1sales_custom-hooks', github: 'marciok/f1sales_custom-hooks', branch: 'master'
gem 'f1sales_helpers', github: 'f1sales/f1sales_helpers', branch: 'master'

gemspec

group :development do
  gem 'rubocop', require: false
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'faker'
end
