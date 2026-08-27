# frozen_string_literal: true

RSpec.describe BaaderBank::Client::Contract do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it '#create_micar_contract posts to micar-contract' do
    stub_api(:post, 'micar-contract')
    client.create_micar_contract({ customer_id: 1 })
    expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/micar-contract')
      .with(body: { customer_id: 1 }.to_json)
  end

  it '#save_consents posts the consents array to contracts/gtc/save-consents' do
    stub_api(:post, 'contracts/gtc/save-consents')
    client.save_consents([{ id: 'gtc-1' }])
    expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/contracts/gtc/save-consents')
      .with(body: [{ id: 'gtc-1' }].to_json)
  end

  it '#outstanding_consents gets the v2 endpoint' do
    stub = stub_api(:get, 'v2/contracts/gtc/1')
    client.outstanding_consents(1)
    expect(stub).to have_been_requested
  end
end
