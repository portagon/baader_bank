# frozen_string_literal: true

module BaaderBank
  class Client
    module CryptoAccount
      def create_crypto_account(attributes)
        post("crypto-accounts", attributes)
      end

      def crypto_account(account_number)
        get("v2/crypto-accounts/#{account_number}")
      end

      def delete_crypto_account(account_number)
        delete("crypto-accounts/#{account_number}")
      end
    end

    include CryptoAccount
  end
end
