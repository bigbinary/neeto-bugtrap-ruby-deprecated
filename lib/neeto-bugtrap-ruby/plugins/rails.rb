# frozen_string_literal: true

require 'neeto-bugtrap-ruby/plugin'

module NeetoBugtrap
  module Plugins
    module Rails
      module ExceptionsCatcher
        # Adds additional NeetoBugtrap info to Request env when an
        # exception is rendered in Rails' middleware.
        #
        # @param [Hash, ActionDispatch::Request] arg The Rack env +Hash+ in
        #   Rails 3.0-4.2. After Rails 5 +arg+ is an +ActionDispatch::Request+.
        # @param [Exception] exception The error which was rescued.
        #
        # @return The super value of the middleware's +#render_exception()+
        #   method.
        def render_exception(arg, exception)
          if arg.is_a?(::ActionDispatch::Request)
            request = arg
            env = request.env
          else
            request = ::Rack::Request.new(arg)
            env = arg
          end

          env['neetobugtrap.exception'] = exception
          env['neetobugtrap.request.url'] = begin
            request.url
          rescue StandardError
            nil
          end

          super(arg, exception)
        end
      end

      class ErrorSubscriber
        def self.report(exception, handled:, severity:, context: {}, source: nil)
          return if source && ::NeetoBugtrap.config[:'rails.subscriber_ignore_sources'].any? do |regex|
                      regex.match?(source)
                    end

          tags = ["severity:#{severity}", "handled:#{handled}"]
          tags << "source:#{source}" if source
          NeetoBugtrap.notify(exception, context: context, tags: tags)
        end
      end

      Plugin.register :rails_exceptions_catcher do
        requirement { defined?(::Rails.application) && ::Rails.application }

        execution do
          require 'rack/request'
          if defined?(::ActionDispatch::DebugExceptions)
            # Rails 3.2.x+
            ::ActionDispatch::DebugExceptions.prepend(ExceptionsCatcher)
          elsif defined?(::ActionDispatch::ShowExceptions)
            # Rails 3.0.x and 3.1.x
            ::ActionDispatch::ShowExceptions.prepend(ExceptionsCatcher)
          end

          if defined?(::ActiveSupport::ErrorReporter)
            # Rails 7
            ::Rails.error.subscribe(ErrorSubscriber)
          end
        end
      end
    end
  end
end
