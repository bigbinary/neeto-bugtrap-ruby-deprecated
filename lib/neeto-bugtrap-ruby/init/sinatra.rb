# frozen_string_literal: true

require 'sinatra/base'
require 'neeto-bugtrap-ruby/ruby'

module NeetoBugtrap
  module Init
    module Sinatra
      ::Sinatra::Base.class_eval do
        class << self
          def build_with_neetobugtrap(*args, &block)
            configure_neetobugtrap
            install_neetobugtrap
            # Sinatra is a special case. Sinatra starts the web application in an at_exit
            # handler. And, since we require sinatra before requiring NB, the only way to
            # setup our at_exit callback is in the sinatra build callback neeto-bugtrap-ruby/init/sinatra.rb
            NeetoBugtrap.install_at_exit_callback
            build_without_neetobugtrap(*args, &block)
          end
          alias_method :build_without_neetobugtrap, :build
          alias_method :build, :build_with_neetobugtrap

          def configure_neetobugtrap
            return unless defined?(neetobugtrap_api_key)

            NeetoBugtrap.configure do |config|
              config.api_key = neetobugtrap_api_key
            end
          end

          def install_neetobugtrap
            config = NeetoBugtrap.config
            return unless config[:'sinatra.enabled']

            install_neetobugtrap_middleware(NeetoBugtrap::Rack::ErrorNotifier) if config[:'exceptions.enabled']
          end

          def install_neetobugtrap_middleware(klass)
            return if middleware.any? { |m| m[0] == klass }

            use(klass)
          end
        end
      end
    end
  end
end

NeetoBugtrap.init!({
                     env: ENV['APP_ENV'] || ENV['RACK_ENV'],
                     framework: :sinatra,
                     'logging.path': 'STDOUT'
                   })

NeetoBugtrap.load_plugins!
