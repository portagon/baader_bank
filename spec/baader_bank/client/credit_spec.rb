# frozen_string_literal: true

RSpec.describe BaaderBank::Client::Credit do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it '#create_credit posts to credit' do
    stub_api(:post, 'credit')
    client.create_credit({ amount: '100.00' })
    expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/credit')
      .with(body: { amount: '100.00' }.to_json)
  end

  it '#confirm_credit puts to credit/confirm' do
    stub_api(:put, 'credit/confirm')
    client.confirm_credit({ id: 1 })
    expect(WebMock).to have_requested(:put, 'https://konto.baaderbank.example/api/credit/confirm')
      .with(body: { id: 1 }.to_json)
  end

  it '#credit_status gets credit/:id' do
    stub = stub_api(:get, 'credit/1')
    client.credit_status(1)
    expect(stub).to have_been_requested
  end

  it '#credit_status_by_ids posts the id list to credit/list' do
    stub_api(:post, 'credit/list')
    client.credit_status_by_ids(%w[a b])
    expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/credit/list')
      .with(body: %w[a b].to_json)
  end

  it '#credit_documents gets credit/documents/:unique_id' do
    stub = stub_api(:get, 'credit/documents/abc')
    client.credit_documents('abc')
    expect(stub).to have_been_requested
  end

  it '#credit_shortfall_documents posts the id list to credit/credit-shortfall-customer' do
    stub_api(:post, 'credit/credit-shortfall-customer')
    client.credit_shortfall_documents(%w[a b])
    expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/credit/credit-shortfall-customer')
      .with(body: %w[a b].to_json)
  end

  describe '#credit_shortfall_customers' do
    it 'gets the v2 asset-manager-scoped endpoint with no query param by default' do
      stub = stub_api(:get, 'v2/credit/credit-shortfall-customer/99')
      client.credit_shortfall_customers(99)
      expect(stub).to have_been_requested
    end

    it 'passes delivery-date when given' do
      stub_request(:get, 'https://konto.baaderbank.example/api/v2/credit/credit-shortfall-customer/99')
        .with(query: { 'delivery-date' => '2026-01-01' })
        .to_return(status: 200, body: '{}')

      client.credit_shortfall_customers(99, delivery_date: '2026-01-01')

      expect(WebMock).to have_requested(:get, 'https://konto.baaderbank.example/api/v2/credit/credit-shortfall-customer/99')
        .with(query: { 'delivery-date' => '2026-01-01' })
    end
  end
end
