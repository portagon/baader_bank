# frozen_string_literal: true

module BaaderBank
  class Client
    # Accounts API - account opening/closing/changing document upload
    # (replacing the SFTP-pushed account-opening ZIP/`.ok` pair), plus cash
    # account balance/transactions.
    module Accounts
      # NOTE: the spec's multipart encoding hint for this endpoint names a
      # single JSON-encoded part called `accountOpeningPayload`, which does
      # not match the flat field list in `UploadAccountOpeningDocumentRequest`
      # (customerId, documentDateTime, accountType, ...). This implements the
      # flat form fields per the schema; verify against the sandbox once
      # available and adjust if Baader actually expects a nested JSON part.
      def upload_opening_documents(zip_file, customer_id:, account_type:, document_date_time: Time.now,
                                   portfolio_number: nil, currency: nil)
        fields = {
          customerId: customer_id,
          accountType: account_type,
          documentDateTime: iso8601_minutes(document_date_time)
        }
        fields[:portfolioNumber] = portfolio_number if portfolio_number
        fields[:currency] = currency if currency

        post_multipart('v2/accounts/upload/opening', file: zip_file, fields: fields)
      end

      def upload_closing_documents(zip_file, customer_id:, document_date_time: Time.now)
        post_multipart(
          'accounts/upload/closing',
          file: zip_file,
          fields: { customerId: customer_id, documentDateTime: iso8601_minutes(document_date_time) }
        )
      end

      def upload_changing_documents(zip_file, customer_id:, modified_attribute:, document_date_time: Time.now,
                                    portfolio_number: nil)
        fields = {
          customerId: customer_id,
          modifiedAttribute: modified_attribute,
          documentDateTime: iso8601_minutes(document_date_time)
        }
        fields[:portfolioNumber] = portfolio_number if portfolio_number

        post_multipart('accounts/upload/changing', file: zip_file, fields: fields)
      end

      def account_balance(account_number)
        get("accounts/#{account_number}/balance")
      end

      def account_transactions(account_number, booking_date: nil, transaction_number_greater_than: nil)
        params = {}
        params['booking-date'] = booking_date if booking_date
        params['transaction-number-greater-than'] = transaction_number_greater_than if transaction_number_greater_than

        get("accounts/#{account_number}/transactions", params)
      end
    end

    include Accounts
  end
end
