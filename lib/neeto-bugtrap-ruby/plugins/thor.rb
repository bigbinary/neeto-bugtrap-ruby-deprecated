# frozen_string_literal: true

require 'neeto-bugtrap-ruby/plugin'
require 'neeto-bugtrap-ruby/ruby'

module NeetoBugtrap
  module Plugins
    module Thor
      def self.included(base)
        base.class_eval do
          no_commands do
            alias_method :invoke_command_without_neetobugtrap, :invoke_command
            alias_method :invoke_command, :invoke_command_with_neetobugtrap
          end
        end
      end

      def invoke_command_with_neetobugtrap(*args)
        invoke_command_without_neetobugtrap(*args)
      rescue Exception => e
        NeetoBugtrap.notify(e)
        raise
      end
    end

    Plugin.register do
      requirement { defined?(::Thor.no_commands) }

      execution do
        ::Thor.include Thor
      end
    end
  end
end
