# frozen_string_literal: true

require_relative 'baader_bank/version'
require_relative 'baader_bank/error'
require_relative 'baader_bank/configuration'
require_relative 'baader_bank/connection'
require_relative 'baader_bank/authenticator'
require_relative 'baader_bank/client'
require_relative 'baader_bank/client/orders'
require_relative 'baader_bank/client/accounts'
require_relative 'baader_bank/client/asset_managers'
require_relative 'baader_bank/client/securities_accounts'
require_relative 'baader_bank/client/model_portfolios'
require_relative 'baader_bank/client/customer'
require_relative 'baader_bank/client/payments'
require_relative 'baader_bank/client/credit'
require_relative 'baader_bank/client/crypto_account'
require_relative 'baader_bank/client/tax'
require_relative 'baader_bank/client/contract'
require_relative 'baader_bank/client/poms_orders'
require_relative 'baader_bank/client/third_party_fx'

module BaaderBank
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def client(configuration = self.configuration)
      Client.new(configuration)
    end
  end
end
