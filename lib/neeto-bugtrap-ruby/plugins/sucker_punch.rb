# frozen_string_literal: true

require 'neeto-bugtrap-ruby/plugin'
require 'neeto-bugtrap-ruby/ruby'

module NeetoBugtrap
  Plugin.register do
    requirement { defined?(::SuckerPunch) }

    execution do
      if SuckerPunch.respond_to?(:exception_handler=) # >= v2
        SuckerPunch.exception_handler = lambda { |ex, klass, args|
          NeetoBugtrap.notify(ex, { component: klass, parameters: args })
        }
      else
        SuckerPunch.exception_handler do |ex, klass, args|
          NeetoBugtrap.notify(ex, { component: klass, parameters: args })
        end
      end
    end
  end
end
