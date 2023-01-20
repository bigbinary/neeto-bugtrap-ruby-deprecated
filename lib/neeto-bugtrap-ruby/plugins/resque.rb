require 'honeybadger/plugin'
require 'honeybadger/ruby'

module NeetoBugtrapRuby
  module Plugins
    module Resque
      module Extension
        # Executed before +on_failure+ hook; the flush is necessary so that
        # errors reported within jobs get sent before the worker dies.
        def around_perform_with_honeybadger(*args)
          NeetoBugtrapRuby.flush { yield }
        end

        def after_perform_with_honeybadger(*args)
          NeetoBugtrapRuby.clear!
        end

        # Error notifications must be synchronous as the +on_failure+ hook is
        # executed after +around_perform+.
        def on_failure_with_honeybadger(e, *args)
          NeetoBugtrapRuby.notify(e, parameters: { job_arguments: args }, sync: true) if send_exception_to_honeybadger?(e, args)
        ensure
          NeetoBugtrapRuby.clear!
        end

        def send_exception_to_honeybadger?(e, args)
          return true unless respond_to?(:retry_criteria_valid?)
          return true if ::NeetoBugtrapRuby.config[:'resque.resque_retry.send_exceptions_when_retrying']

          !retry_criteria_valid?(e)
        rescue => e
          NeetoBugtrapRuby.notify(e, parameters: { job_arguments: args }, sync: true)
        end
      end

      module Installer
        def self.included(base)
          base.send(:alias_method, :payload_class_without_honeybadger, :payload_class)
          base.send(:alias_method, :payload_class, :payload_class_with_honeybadger)
        end

        def payload_class_with_honeybadger
          payload_class_without_honeybadger.tap do |klass|
            unless klass.respond_to?(:around_perform_with_honeybadger)
              klass.instance_eval do
                extend(::NeetoBugtrapRuby::Plugins::Resque::Extension)
              end
            end
          end
        end
      end

      Plugin.register do
        requirement { defined?(::Resque::Job) }

        requirement do
          if resque_honeybadger = defined?(::Resque::Failure::NeetoBugtrapRuby)
            logger.warn("Support for Resque has been moved " \
                        "to the honeybadger gem. Please remove " \
                        "resque-honeybadger from your " \
                        "Gemfile.")
          end
          !resque_honeybadger
        end

        execution do
          ::Resque::Job.send(:include, Installer)
        end
      end
    end
  end
end
