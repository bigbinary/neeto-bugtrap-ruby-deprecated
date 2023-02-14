# frozen_string_literal: true

require 'delayed_job'
require 'neeto-bugtrap-ruby/ruby'

module NeetoBugtrap
  module Plugins
    module DelayedJob
      class Plugin < ::Delayed::Plugin
        callbacks do |lifecycle|
          lifecycle.around(:invoke_job) do |job, &block|
            begin
              if job.payload_object.instance_of?(::ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper)
                # buildin support for Rails 4.2 ActiveJob
                component = job.payload_object.job_data['job_class']
                action = 'perform'
              else
                # buildin support for Delayed::PerformableMethod
                component = job.payload_object.object.is_a?(Class) ? job.payload_object.object.name : job.payload_object.object.class.name
                action    = job.payload_object.method_name.to_s
              end
            rescue StandardError # fallback to support all other classes
              component = job.payload_object.class.name
              action    = 'perform'
            end

            ::NeetoBugtrap.context(
              component: component,
              action: action,
              job_id: job.id,
              handler: job.handler,
              last_error: job.last_error,
              attempts: job.attempts,
              queue: job.queue
            )

            block.call(job)
          rescue Exception => e
            if job.attempts.to_i >= ::NeetoBugtrap.config[:'delayed_job.attempt_threshold'].to_i
              ::NeetoBugtrap.notify(
                component: component,
                action: action,
                error_class: e.class.name,
                error_message: "#{e.class.name}: #{e.message}",
                backtrace: e.backtrace,
                exception: e
              )
            end
            raise e
          ensure
            ::NeetoBugtrap.clear!
          end
        end
      end
    end
  end
end
