# frozen_string_literal: true

require 'net/http'
require 'json'
require 'zlib'
require 'openssl'

require 'neeto-bugtrap-ruby/backend/base'
require 'neeto-bugtrap-ruby/util/http'

module NeetoBugtrap
  module Backend
    class Server < Base
      ENDPOINTS = {
        notices: '/api/v1/notices',
        deploys: '/v1/deploys'
      }.freeze

      CHECK_IN_ENDPOINT = '/v1/check_in'

      HTTP_ERRORS = Util::HTTP::ERRORS

      def initialize(config)
        @http = Util::HTTP.new(config)
        super
      end

      # Post payload to endpoint for feature.
      #
      # @param [Symbol] feature The feature which is being notified.
      # @param [#to_json] payload The JSON payload to send.
      #
      # @return [Response]
      def notify(feature, payload)
        ENDPOINTS[feature] or raise(BackendError, "Unknown feature: #{feature}")
        Response.new(@http.post(ENDPOINTS[feature], payload, payload_headers(payload)))
      rescue *HTTP_ERRORS => e
        Response.new(:error, nil, "HTTP Error: #{e.class}")
      end

      # Does a check in using the input id.
      #
      # @param [String] id The unique check_in id.
      #
      # @return [Response]
      def check_in(id)
        Response.new(@http.get("#{CHECK_IN_ENDPOINT}/#{id}"))
      rescue *HTTP_ERRORS => e
        Response.new(:error, nil, "HTTP Error: #{e.class}")
      end

      private

      def payload_headers(payload)
        return unless payload.respond_to?(:api_key) && payload.api_key

        {
          'X-API-Key' => payload.api_key
        }
      end
    end
  end
end
