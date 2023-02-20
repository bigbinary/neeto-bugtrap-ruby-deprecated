source 'https://rubygems.org'

gemspec

gem 'allocation_stats', platforms: :mri, require: false
gem 'appraisal', '~> 2.1'
gem 'aruba', '~> 2.0'
gem 'rspec', '~> 3.0'
gem 'rspec-its'
gem 'ruby-prof', platforms: :mri, require: false
gem 'timecop'
gem 'webmock'

# Required by feature specs.
gem 'capistrano'
gem 'rake'

# mathn has moved to a rubygem in Ruby 2.5.0: https://github.com/ruby/mathn
platforms :ruby_25 do
  gem "mathn"
end

gem "bump", "~> 0.10.0"

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'pry'
  gem 'pry-byebug', platforms: :mri
  gem 'rdoc'
end

group :development, :test do
  source "https://O6Ts9-SVDaUZpHMRs2CpJp22RwbETDE@gems.neeto.com" do

    # neeto-commons-backend gem for methods and modules that are used across all neeto products.
    gem "neeto-commons-backend"

    # For neeto audit
    gem "neeto-compliance"

  end
end


