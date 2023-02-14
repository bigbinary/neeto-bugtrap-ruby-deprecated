# frozen_string_literal: true

if defined?(::Rails::Railtie)
  require 'neeto-bugtrap-ruby/init/rails'
elsif defined?(Sinatra::Base)
  require 'neeto-bugtrap-ruby/init/sinatra'
else
  require 'neeto-bugtrap-ruby/init/ruby'
end

require 'neeto-bugtrap-ruby/init/rake' if defined?(Rake.application)
