# frozen_string_literal: true

module BaaderBank
  class Client
    module Customer
      # No v2 replacement is documented for this base lookup - deprecated
      # with no alternative listed.
      def customer(customer_id)
        get("customers/#{customer_id}")
      end

      def end_customer(customer_id)
        get("customers/endcustomer/#{customer_id}")
      end

      def customer_relationships(customer_id)
        get("v2/customers/relationships/#{customer_id}")
      end

      def customer_reference_accounts(customer_id)
        get("v2/customers/#{customer_id}/referenceaccounts")
      end

      def customer_locks(customer_id)
        get("v2/customers/#{customer_id}/locks")
      end

      def customer_balance(customer_id)
        get("customers/#{customer_id}/balance")
      end

      def customer_intraday_payments(customer_id, booking_date: nil)
        params = booking_date ? { 'booking-date' => booking_date } : {}
        get("v2/customers/#{customer_id}/intraday-payments", params)
      end

      def customer_intraday_account_openings(customer_id, account_opening_date: nil)
        params = account_opening_date ? { 'account-opening-date' => account_opening_date } : {}
        get("v2/customers/#{customer_id}/intraday-account-openings", params)
      end

      # No v2 replacement documented for interday-* customer endpoints.
      def customer_interday_payments(customer_id, booking_date: nil)
        params = booking_date ? { 'booking-date' => booking_date } : {}
        get("customers/#{customer_id}/interday-payments", params)
      end

      def customer_interday_account_openings(customer_id, account_opening_date: nil)
        params = account_opening_date ? { 'account-opening-date' => account_opening_date } : {}
        get("customers/#{customer_id}/interday-account-openings", params)
      end
    end

    include Customer
  end
end
