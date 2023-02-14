# frozen_string_literal: true

module NeetoBugtrap
  module Breadcrumbs
    # @api private
    #
    module LogWrapper
      def add(severity, message = nil, progname = nil)
        org_severity = severity
        org_message = message
        org_progname = progname
        if message.nil?
          message = progname
          progname = nil
        end
        message = message&.to_s&.strip
        unless should_ignore_log?(message, progname)
          NeetoBugtrap.add_breadcrumb(message, category: :log, metadata: {
                                        severity: format_severity(severity),
                                        progname: progname
                                      })
        end

        super(org_severity, org_message, org_progname)
      end

      private

      def should_ignore_log?(message, progname)
        message.nil? ||
          message == '' ||
          Thread.current[:__nb_within_log_subscriber] ||
          progname == 'neetobugtrap'
      end
    end

    # @api private
    #
    # This module is designed to be prepended into the
    # ActiveSupport::LogSubscriber for the sole purpose of silencing breadcrumb
    # log events. Since we already have specific breadcrumb events for each
    # class that provides LogSubscriber events, we want to filter out those
    # logs as they just become noise.
    module LogSubscriberInjector
      %w[info debug warn error fatal unknown].each do |level|
        define_method(level) do |*args, &block|
          Thread.current[:__nb_within_log_subscriber] = true
          super(*args, &block)
        ensure
          Thread.current[:__nb_within_log_subscriber] = false
        end
      end
    end
  end
end
