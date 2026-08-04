# frozen_string_literal: true

require "faraday"
require "faraday/multipart"

module BaaderBank
  # Builds the shared Faraday connection used by both the Authenticator
  # (unauthenticated /login, /token/refresh calls) and Client (authenticated
  # resource calls). Kept separate from Client so Authenticator does not need
  # a full Client instance to bootstrap a token.
  module Connection
    def self.build(configuration)
      Faraday.new(url: configuration.base_url) do |conn|
        conn.request :multipart
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.headers["x-api-key"] = configuration.api_key
        conn.options.timeout = configuration.timeout
        conn.options.open_timeout = configuration.open_timeout
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
