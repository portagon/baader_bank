# frozen_string_literal: true

RSpec.describe BaaderBank::Client::CryptoAccount do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it '#create_crypto_account posts to crypto-accounts' do
    stub_api(:post, 'crypto-accounts')
    client.create_crypto_account({ account_number: '1' })
    expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/crypto-accounts')
      .with(body: { account_number: '1' }.to_json)
  end

  it '#crypto_account gets the v2 endpoint' do
    stub = stub_api(:get, 'v2/crypto-accounts/1')
    client.crypto_account(1)
    expect(stub).to have_been_requested
  end

  it '#delete_crypto_account deletes crypto-accounts/:number' do
    stub = stub_api(:delete, 'crypto-accounts/1')
    client.delete_crypto_account(1)
    expect(stub).to have_been_requested
  end
end
