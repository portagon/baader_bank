# frozen_string_literal: true

module BaaderBank
  class Client
    module PomsOrders
      def poms_orders(securities_account_number)
        get("securities-accounts/#{securities_account_number}/poms-orders")
      end
    end

    include PomsOrders
  end
end
