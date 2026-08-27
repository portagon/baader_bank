# frozen_string_literal: true

module BaaderBank
  class Client
    module SecuritiesAccounts
      def securities_account(securities_account_number)
        get("securities-accounts/#{securities_account_number}")
      end

      def securities_account_transactions(securities_account_number, booking_date: nil,
                                          transaction_number_greater_than: nil)
        params = {}
        params['booking-date'] = booking_date if booking_date
        params['transaction-number-greater-than'] = transaction_number_greater_than if transaction_number_greater_than

        get("securities-accounts/#{securities_account_number}/transactions", params)
      end

      def securities_account_performance(securities_account_number, from_date: nil)
        params = from_date ? { 'fromDate' => from_date } : {}
        get("securities-accounts/#{securities_account_number}/performance", params)
      end

      def investment_profiles(securities_account_number: nil)
        params = securities_account_number ? { 'securities-account-number' => securities_account_number } : {}
        get('securities-accounts/investment-profiles', params)
      end

      def submit_investment_profiles(attributes)
        post('securities-accounts/investment-profiles', attributes)
      end

      # No v2 replacement is documented - deprecated with no alternative listed.
      def deposit_mt535(securities_account)
        get("deposits/#{securities_account}/mt535")
      end
    end

    include SecuritiesAccounts
  end
end
