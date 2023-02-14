# frozen_string_literal: true

require 'neeto-bugtrap-ruby/version'

module NeetoBugtrap
  module Rack
    # Autoloading allows middleware classes to be referenced in applications
    # which include the optional Rack dependency without explicitly requiring
    # these files.
    autoload :ErrorNotifier, 'neeto-bugtrap-ruby/rack/error_notifier'
    autoload :UserFeedback, 'neeto-bugtrap-ruby/rack/user_feedback'
    autoload :UserInformer, 'neeto-bugtrap-ruby/rack/user_informer'
  end

  # @api private
  module Plugins
  end

  # @api private
  module Util
  end
end
