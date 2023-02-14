# frozen_string_literal: true

require 'English'

require 'bundler'

catch :failure do
  Dir['spec/unit/**/*_spec.rb'].each do |s|
    Bundler.with_unbundled_env { puts `bundle exec rspec --pattern #{s}` }
    throw :failure unless $CHILD_STATUS.exitstatus.zero?
  end
end
