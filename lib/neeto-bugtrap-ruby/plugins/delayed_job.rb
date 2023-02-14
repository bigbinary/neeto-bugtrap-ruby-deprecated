# frozen_string_literal: true

require 'neeto-bugtrap-ruby/plugin'

module NeetoBugtrap
  Plugin.register do
    requirement { defined?(::Delayed::Plugin) }
    requirement { defined?(::Delayed::Worker.plugins) }
    requirement do
      if (delayed_job_neetobugtrap = defined?(::Delayed::Plugins::NeetoBugtrap))
        logger.warn('Support for Delayed Job has been moved ' \
                    'to the neetobugtrap gem. Please remove ' \
                    'delayed_job_neetobugtrap from your ' \
                    'Gemfile.')
      end
      !delayed_job_neetobugtrap
    end

    execution do
      require 'neeto-bugtrap-ruby/plugins/delayed_job/plugin'
      ::Delayed::Worker.plugins << Plugins::DelayedJob::Plugin
    end
  end
end
