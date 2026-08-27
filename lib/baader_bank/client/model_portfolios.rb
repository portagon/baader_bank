# frozen_string_literal: true

module BaaderBank
  class Client
    module ModelPortfolios
      def model_portfolios
        get('model-portfolios')
      end

      def model_portfolio(model_portfolio_id)
        get("model-portfolios/#{model_portfolio_id}")
      end

      def create_model_portfolio(attributes)
        post('model-portfolios', attributes)
      end

      def update_model_portfolio(model_portfolio_id, attributes)
        put("model-portfolios/#{model_portfolio_id}", attributes)
      end

      def delete_model_portfolio(model_portfolio_id)
        delete("model-portfolios/#{model_portfolio_id}")
      end
    end

    include ModelPortfolios
  end
end
