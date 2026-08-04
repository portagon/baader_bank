# frozen_string_literal: true

RSpec.describe BaaderBank::Client::ThirdPartyFx do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it "#create_third_party_forex_transaction posts to third-party/forex" do
    stub_api(:post, "third-party/forex")
    client.create_third_party_forex_transaction({ amount: "100.00" })
    expect(WebMock).to have_requested(:post, "https://konto.baaderbank.example/api/third-party/forex")
      .with(body: { amount: "100.00" }.to_json)
  end
end
