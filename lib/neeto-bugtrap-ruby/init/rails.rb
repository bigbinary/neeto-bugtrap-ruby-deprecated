# frozen_string_literal: true

require 'rails'
require 'yaml'

require 'neeto-bugtrap-ruby/ruby'

module NeetoBugtrap
  module Init
    module Rails
      class Railtie < ::Rails::Railtie
        rake_tasks do
          load 'neeto-bugtrap-ruby/tasks.rb'
        end

        initializer 'neetobugtrap.install_middleware' do |app|
          app.config.middleware.insert(0, NeetoBugtrap::Rack::ErrorNotifier)
          app.config.middleware.insert_before(NeetoBugtrap::Rack::ErrorNotifier, NeetoBugtrap::Rack::UserInformer)
          app.config.middleware.insert_before(NeetoBugtrap::Rack::ErrorNotifier, NeetoBugtrap::Rack::UserFeedback)
        end

        config.before_initialize do
          NeetoBugtrap.init!({
                               root: ::Rails.root.to_s,
                               env: ::Rails.env,
                               'config.path': ::Rails.root.join('config', 'neetobugtrap.yml'),
                               logger: Logging::FormattedLogger.new(::Rails.logger),
                               framework: :rails
                             })
        end

        config.after_initialize do
          NeetoBugtrap.load_plugins!
        end
      end
    end
  end
end

NeetoBugtrap.install_at_exit_callback
