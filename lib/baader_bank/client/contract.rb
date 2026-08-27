# frozen_string_literal: true

module BaaderBank
  class Client
    module Contract
      def create_micar_contract(attributes)
        post('micar-contract', attributes)
      end

      def save_consents(consents)
        post('contracts/gtc/save-consents', consents)
      end

      def outstanding_consents(customer_id)
        get("v2/contracts/gtc/#{customer_id}")
      end
    end

    include Contract
  end
end
