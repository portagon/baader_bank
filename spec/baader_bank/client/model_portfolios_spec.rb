# frozen_string_literal: true

RSpec.describe BaaderBank::Client::ModelPortfolios do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it "#model_portfolios gets model-portfolios" do
    stub = stub_api(:get, "model-portfolios")
    client.model_portfolios
    expect(stub).to have_been_requested
  end

  it "#model_portfolio gets model-portfolios/:id" do
    stub = stub_api(:get, "model-portfolios/1")
    client.model_portfolio(1)
    expect(stub).to have_been_requested
  end

  it "#create_model_portfolio posts to model-portfolios" do
    stub_api(:post, "model-portfolios")
    client.create_model_portfolio({ name: "Growth" })
    expect(WebMock).to have_requested(:post, "https://konto.baaderbank.example/api/model-portfolios")
      .with(body: { name: "Growth" }.to_json)
  end

  it "#update_model_portfolio puts to model-portfolios/:id" do
    stub_api(:put, "model-portfolios/1")
    client.update_model_portfolio(1, { name: "Renamed" })
    expect(WebMock).to have_requested(:put, "https://konto.baaderbank.example/api/model-portfolios/1")
      .with(body: { name: "Renamed" }.to_json)
  end

  it "#delete_model_portfolio deletes model-portfolios/:id" do
    stub = stub_api(:delete, "model-portfolios/1")
    client.delete_model_portfolio(1)
    expect(stub).to have_been_requested
  end
end
