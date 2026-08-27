# frozen_string_literal: true

module BaaderBank
  class Client
    # Orders API - the endpoint that replaces the SFTP-pushed block-order
    # and breakdown ZIP/`.ok` file pairs. There is a single upload endpoint;
    # Baader has not yet confirmed (as of writing) whether block-order and
    # breakdown ZIPs need to be distinguished via metadata beyond their
    # content - see the open questions sent to Baader.
    module Orders
      # Uploads a block-order or breakdown ZIP for the daily ordering
      # process. A `202` response (returned as `nil` body) means the upload
      # was accepted - unlike the old SFTP `.ok` file, this does not by
      # itself confirm the file was processed successfully, only received.
      def upload_order_documents(zip_file, document_date_time: Time.now)
        post_multipart(
          'orders/upload/ordering',
          file: zip_file,
          fields: { documentDateTime: iso8601_millis(document_date_time) }
        )
      end
    end

    include Orders
  end
end
