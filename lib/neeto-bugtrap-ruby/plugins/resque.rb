# frozen_string_literal: true

require 'neeto-bugtrap-ruby/plugin'
require 'neeto-bugtrap-ruby/ruby'

module NeetoBugtrap
  module Plugins
    module Resque
      module Extension
        # Executed before +on_failure+ hook; the flush is necessary so that
        # errors reported within jobs get sent before the worker dies.
        def around_perform_with_neetobugtrap(*_args, &block)
          NeetoBugtrap.flush(&block)
        end

        def after_perform_with_neetobugtrap(*_args)
          NeetoBugtrap.clear!
        end

        # Error notifications must be synchronous as the +on_failure+ hook is
        # executed after +around_perform+.
        def on_failure_with_neetobugtrap(e, *args)
          NeetoBugtrap.notify(e, parameters: { job_arguments: args }, sync: true) if send_exception_to_neetobugtrap?(e,
                                                                                                                     args)
        ensure
          NeetoBugtrap.clear!
        end

        def send_exception_to_neetobugtrap?(e, args)
          return true unless respond_to?(:retry_criteria_valid?)
          return true if ::NeetoBugtrap.config[:'resque.resque_retry.send_exceptions_when_retrying']

          !retry_criteria_valid?(e)
        rescue StandardError => e
          NeetoBugtrap.notify(e, parameters: { job_arguments: args }, sync: true)
        end
      end

      module Installer
        def self.included(base)
          base.send(:alias_method, :payload_class_without_neetobugtrap, :payload_class)
          base.send(:alias_method, :payload_class, :payload_class_with_neetobugtrap)
        end

        def payload_class_with_neetobugtrap
          payload_class_without_neetobugtrap.tap do |klass|
            unless klass.respond_to?(:around_perform_with_neetobugtrap)
              klass.instance_eval do
                extend(::NeetoBugtrap::Plugins::Resque::Extension)
              end
            end
          end
        end
      end

      Plugin.register do
        requirement { defined?(::Resque::Job) }

        requirement do
          if (resque_neetobugtrap = defined?(::Resque::Failure::NeetoBugtrap))
            logger.warn('Support for Resque has been moved ' \
                        'to the neetobugtrap gem. Please remove ' \
                        'resque-neetobugtrap from your ' \
                        'Gemfile.')
          end
          !resque_neetobugtrap
        end

        execution do
          ::Resque::Job.include Installer
        end
      end
    end
  end
end
