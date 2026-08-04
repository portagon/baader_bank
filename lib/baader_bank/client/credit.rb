# frozen_string_literal: true

module BaaderBank
  class Client
    module Credit
      def create_credit(attributes)
        post("credit", attributes)
      end

      def confirm_credit(attributes)
        put("credit/confirm", attributes)
      end

      def credit_status(id)
        get("credit/#{id}")
      end

      def credit_status_by_ids(unique_ids)
        post("credit/list", unique_ids)
      end

      def credit_documents(unique_id)
        get("credit/documents/#{unique_id}")
      end

      def credit_shortfall_documents(unique_ids)
        post("credit/credit-shortfall-customer", unique_ids)
      end

      def credit_shortfall_customers(asset_manager_id, delivery_date: nil)
        params = delivery_date ? { "delivery-date" => delivery_date } : {}
        get("v2/credit/credit-shortfall-customer/#{asset_manager_id}", params)
      end
    end

    include Credit
  end
end
