require 'forwardable'

require 'neeto-bugtrap-ruby/backend/base'
require 'neeto-bugtrap-ruby/backend/server'
require 'neeto-bugtrap-ruby/backend/test'
require 'neeto-bugtrap-ruby/backend/null'
require 'neeto-bugtrap-ruby/backend/debug'

module NeetoBugtrapRuby
  # @api private
  module Backend
    class BackendError < StandardError; end

    def self.mapping
      @@mapping ||= {
        server: Server,
        test: Test,
        null: Null,
        debug: Debug
      }.freeze
    end

    def self.for(backend)
      mapping[backend] or raise(BackendError, "Unable to locate backend: #{backend}")
    end
  end
end
