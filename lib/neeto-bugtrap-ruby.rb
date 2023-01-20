if defined?(::Rails::Railtie)
  require 'neeto-bugtrap-ruby/init/rails'
elsif defined?(Sinatra::Base)
  require 'neeto-bugtrap-ruby/init/sinatra'
else
  require 'neeto-bugtrap-ruby/init/ruby'
end

if defined?(Rake.application)
  require 'neeto-bugtrap-ruby/init/rake'
end
