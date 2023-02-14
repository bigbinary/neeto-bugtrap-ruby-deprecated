# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../../vendor/cli', __dir__))

require 'thor'

require 'neeto-bugtrap-ruby/cli/main'

module NeetoBugtrap
  # @api private
  module CLI
    def self.start(*args)
      Main.start(*args)
    end
  end
end
