require 'neeto-bugtrap-ruby/plugin'
require 'neeto-bugtrap-ruby/ruby'

module NeetoBugtrap
  Plugin.register do
    requirement { defined?(::Warden::Manager.after_set_user) }

    execution do
      ::Warden::Manager.after_set_user do |user, auth, opts|
        if user.respond_to?(:id)
          ::NeetoBugtrap.context({
            :user_scope => opts[:scope].to_s,
            :user_id => user.id.to_s
          })
        end
      end
    end
  end
end
