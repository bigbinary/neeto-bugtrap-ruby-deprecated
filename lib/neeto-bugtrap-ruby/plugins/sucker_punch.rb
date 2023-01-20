require 'honeybadger/plugin'
require 'honeybadger/ruby'

module NeetoBugtrapRuby
  Plugin.register do
    requirement { defined?(::SuckerPunch) }

    execution do
      if SuckerPunch.respond_to?(:exception_handler=) # >= v2
        SuckerPunch.exception_handler = ->(ex, klass, args) { NeetoBugtrapRuby.notify(ex, { :component => klass, :parameters => args }) }
      else
        SuckerPunch.exception_handler do |ex, klass, args|
          NeetoBugtrapRuby.notify(ex, { :component => klass, :parameters => args })
        end
      end
    end
  end
end
