# frozen_string_literal: true

module BaaderBank
  class Client
    module Tax
      def tax_master_data(customer_id)
        get("v2/tax/#{customer_id}/tax-master-data")
      end
    end

    include Tax
  end
end
