require 'neeto-bugtrap-ruby/backend/base'

module NeetoBugtrap
  module Backend
    class Null < Base
      class StubbedResponse < Response
        def initialize
          super(:stubbed, '{}'.freeze)
        end

        def success?
          true
        end
      end

      def initialize(*args)
        super
      end

      def notify(feature, payload)
        StubbedResponse.new
      end

      def check_in(id)
        StubbedResponse.new
      end
    end
  end
end
