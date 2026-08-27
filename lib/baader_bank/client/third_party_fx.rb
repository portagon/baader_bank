# frozen_string_literal: true

module BaaderBank
  class Client
    module ThirdPartyFx
      def create_third_party_forex_transaction(attributes)
        post('third-party/forex', attributes)
      end
    end

    include ThirdPartyFx
  end
end
