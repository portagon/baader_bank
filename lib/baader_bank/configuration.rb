# frozen_string_literal: true

module BaaderBank
  # Holds connection and credential settings. Configure once via
  # `BaaderBank.configure`, typically from a Rails initializer:
  #
  #   BaaderBank.configure do |config|
  #     config.base_url = "https://konto.baaderbank.de/api"
  #     config.api_key  = ENV.fetch("BAADER_BANK_API_KEY")
  #     config.user_id  = ENV.fetch("BAADER_BANK_USER_ID")
  #     config.pin      = ENV.fetch("BAADER_BANK_PIN")
  #   end
  class Configuration
    DEFAULT_BASE_URL = 'https://konto.baaderbank.de/api/'
    DEFAULT_TIMEOUT = 30
    DEFAULT_OPEN_TIMEOUT = 10

    attr_reader :base_url
    attr_accessor :api_key, :user_id, :pin, :timeout, :open_timeout, :proxy, :token_store, :logger

    def initialize
      @base_url = DEFAULT_BASE_URL
      @timeout = DEFAULT_TIMEOUT
      @open_timeout = DEFAULT_OPEN_TIMEOUT
      @proxy = nil
      @token_store = nil # defaults to Authenticator::MemoryTokenStore, see Authenticator#initialize
    end

    # All resource paths are relative (no leading slash) so that Faraday's
    # URI joining appends them to the full `base_url` path instead of
    # replacing it - which requires `base_url` to always end in "/".
    def base_url=(url)
      @base_url = url.to_s.end_with?('/') ? url.to_s : "#{url}/"
    end
  end
end
