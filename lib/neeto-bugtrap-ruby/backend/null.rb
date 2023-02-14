# frozen_string_literal: true

require 'neeto-bugtrap-ruby/backend/base'

module NeetoBugtrap
  module Backend
    class Null < Base
      class StubbedResponse < Response
        def initialize
          super(:stubbed, '{}')
        end

        def success?
          true
        end
      end

      def initialize(*args)
        super
      end

      def notify(_feature, _payload)
        StubbedResponse.new
      end

      def check_in(_id)
        StubbedResponse.new
      end
    end
  end
end
