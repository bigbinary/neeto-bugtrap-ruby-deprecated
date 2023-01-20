require 'neeto-bugtrap-ruby/plugin'
require 'neeto-bugtrap-ruby/agent'

module NeetoBugtrapRuby
  module Plugins
    module Passenger
      Plugin.register do
        requirement { defined?(::PhusionPassenger.on_event) }

        execution do
          ::PhusionPassenger.on_event(:starting_worker_process) do |forked|
            logger.debug('Starting passenger worker process')
          end

          ::PhusionPassenger.on_event(:stopping_worker_process) do
            logger.debug('Stopping passenger worker process')
            NeetoBugtrapRuby.stop
          end
        end
      end
    end
  end
end
