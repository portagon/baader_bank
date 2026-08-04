# frozen_string_literal: true

require "monitor"

module BaaderBank
  # Obtains and refreshes the JWT used to authorize resource calls.
  #
  # The API's documented access-token lifetime is inconsistent (60 minutes
  # per the security scheme description, 5 minutes per the refresh endpoint
  # description) - so this never assumes a duration. It always reads
  # `expires_on` from the actual login/refresh response and refreshes a
  # little ahead of that.
  #
  # Token refresh itself requires *both* a valid refresh token *and* the
  # last-known access token as a Bearer header (per the OpenAPI security
  # requirement on POST /token/refresh) - not just the refresh token alone.
  class Authenticator
    include MonitorMixin

    EXPIRY_BUFFER_SECONDS = 30

    def initialize(configuration)
      super()
      @configuration = configuration
      @connection = Connection.build(configuration)
      @token_store = configuration.token_store || MemoryTokenStore.new
    end

    # Returns a valid access token, logging in or refreshing as needed.
    def access_token
      synchronize do
        token = @token_store.read
        return token[:access_token] if token && !expired?(token)

        token = (token && refresh!(token)) || login!
        token[:access_token]
      end
    end

    # Forces the next #access_token call to obtain a fresh token.
    def invalidate!
      synchronize { @token_store.write(nil) }
    end

    private

    def expired?(token)
      Time.now.to_i >= (token[:expires_on] - EXPIRY_BUFFER_SECONDS)
    end

    def login!
      response = @connection.post("login") do |req|
        req.body = { user_id: @configuration.user_id, pin: @configuration.pin }
      end
      store_identity_response(response)
    rescue Faraday::Error => e
      raise error_from_faraday(e)
    end

    def refresh!(current_token)
      response = @connection.post("token/refresh") do |req|
        req.headers["Authorization"] = "Bearer #{current_token[:access_token]}"
        req.body = { grant_type: "refresh_token", refresh_token: current_token[:refresh_token] }
      end
      store_identity_response(response)
    rescue Faraday::Error, Error
      nil # fall back to a fresh login rather than raising on an expired/invalid refresh token
    end

    def store_identity_response(response)
      raise_if_error!(response)

      body = response.body
      token = {
        access_token: body["access_token"],
        refresh_token: body["refresh_token"],
        expires_on: body["expires_on"]
      }
      @token_store.write(token)
      token
    end

    def raise_if_error!(response)
      error = Error.from_response(response.status, response.body)
      raise error if error
    end

    def error_from_faraday(faraday_error)
      response = faraday_error.response
      return Error.new(detail: faraday_error.message) unless response

      Error.from_response(response[:status], response[:body]) ||
        Error.new(status: response[:status], detail: faraday_error.message)
    end

    # Default in-process token store. Not shared across processes/dynos -
    # host apps running multiple workers should inject a shared store (e.g.
    # backed by Rails.cache) via `configuration.token_store`.
    class MemoryTokenStore
      def initialize
        @token = nil
      end

      def read
        @token
      end

      def write(token)
        @token = token
      end
    end
  end
end
