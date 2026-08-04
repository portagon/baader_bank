# frozen_string_literal: true

RSpec.describe BaaderBank::Client::Payments do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  %i[sepa_direct_debit sepa_direct_debit_instant sepa_credit_transfer].each do |method|
    path = "payments/#{method.to_s.tr("_", "-")}"

    it "##{method} posts the raw XML document to #{path}" do
      xml = "<Document/>"
      stub_request(:post, "https://konto.baaderbank.example/api/#{path}")
        .with(body: xml, headers: { "Content-Type" => "application/xml" })
        .to_return(status: 202)

      client.public_send(method, xml)

      expect(WebMock).to have_requested(:post, "https://konto.baaderbank.example/api/#{path}").with(body: xml)
    end
  end

  it "#create_portfolio_payout posts JSON to payments/portfolio-payouts" do
    stub_api(:post, "payments/portfolio-payouts")
    client.create_portfolio_payout({ amount: "100.00" })
    expect(WebMock).to have_requested(:post, "https://konto.baaderbank.example/api/payments/portfolio-payouts")
      .with(body: { amount: "100.00" }.to_json)
  end

  it "#create_basic_direct_debit posts JSON to payments/basic-direct-debits" do
    stub_api(:post, "payments/basic-direct-debits")
    client.create_basic_direct_debit({ amount: "50.00" })
    expect(WebMock).to have_requested(:post, "https://konto.baaderbank.example/api/payments/basic-direct-debits")
      .with(body: { amount: "50.00" }.to_json)
  end

  it "#open_portfolio_payouts gets the securities-account-scoped endpoint" do
    stub = stub_api(:get, "securities-accounts/555/payments/portfolio-payouts")
    client.open_portfolio_payouts(555)
    expect(stub).to have_been_requested
  end
end
