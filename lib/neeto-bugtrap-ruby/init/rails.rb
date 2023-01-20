require 'rails'
require 'yaml'

require 'neeto-bugtrap-ruby/ruby'

module NeetoBugtrapRuby
  module Init
    module Rails
      class Railtie < ::Rails::Railtie
        rake_tasks do
          load 'neeto-bugtrap-ruby/tasks.rb'
        end

        initializer 'honeybadger.install_middleware' do |app|
          app.config.middleware.insert(0, NeetoBugtrapRuby::Rack::ErrorNotifier)
          app.config.middleware.insert_before(NeetoBugtrapRuby::Rack::ErrorNotifier, NeetoBugtrapRuby::Rack::UserInformer)
          app.config.middleware.insert_before(NeetoBugtrapRuby::Rack::ErrorNotifier, NeetoBugtrapRuby::Rack::UserFeedback)
        end

        config.before_initialize do
          NeetoBugtrapRuby.init!({
            :root           => ::Rails.root.to_s,
            :env            => ::Rails.env,
            :'config.path'  => ::Rails.root.join('config', 'honeybadger.yml'),
            :logger         => Logging::FormattedLogger.new(::Rails.logger),
            :framework      => :rails
          })
        end

        config.after_initialize do
          NeetoBugtrapRuby.load_plugins!
        end
      end
    end
  end
end

NeetoBugtrapRuby.install_at_exit_callback
