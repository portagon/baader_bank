# frozen_string_literal: true

module BaaderBank
  class Client
    # SEPA transfer/debit endpoints take a raw ISO 20022 XML document
    # (`pain.001`/`pain.008`-style) rather than JSON - callers build the XML
    # themselves and pass it as a string.
    module Payments
      def sepa_direct_debit(xml_document)
        post_xml('payments/sepa-direct-debit', xml_document)
      end

      def sepa_direct_debit_instant(xml_document)
        post_xml('payments/sepa-direct-debit-instant', xml_document)
      end

      def sepa_credit_transfer(xml_document)
        post_xml('payments/sepa-credit-transfer', xml_document)
      end

      def create_portfolio_payout(attributes)
        post('payments/portfolio-payouts', attributes)
      end

      def create_basic_direct_debit(attributes)
        post('payments/basic-direct-debits', attributes)
      end

      def open_portfolio_payouts(securities_account_number)
        get("securities-accounts/#{securities_account_number}/payments/portfolio-payouts")
      end
    end

    include Payments
  end
end
