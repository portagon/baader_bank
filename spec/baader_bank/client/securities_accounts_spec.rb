# frozen_string_literal: true

RSpec.describe BaaderBank::Client::SecuritiesAccounts do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it '#securities_account gets securities-accounts/:number' do
    stub = stub_api(:get, 'securities-accounts/555')
    client.securities_account(555)
    expect(stub).to have_been_requested
  end

  describe '#securities_account_transactions' do
    it 'gets the transactions endpoint with no query params by default' do
      stub = stub_api(:get, 'securities-accounts/555/transactions')
      client.securities_account_transactions(555)
      expect(stub).to have_been_requested
    end

    it 'passes booking-date and transaction-number-greater-than when given' do
      stub_request(:get, 'https://konto.baaderbank.example/api/securities-accounts/555/transactions')
        .with(query: { 'booking-date' => '2026-01-01', 'transaction-number-greater-than' => '5' })
        .to_return(status: 200, body: '{}')

      client.securities_account_transactions(555, booking_date: '2026-01-01', transaction_number_greater_than: '5')

      expect(WebMock).to have_requested(:get, 'https://konto.baaderbank.example/api/securities-accounts/555/transactions')
        .with(query: { 'booking-date' => '2026-01-01', 'transaction-number-greater-than' => '5' })
    end
  end

  describe '#securities_account_performance' do
    it 'gets the performance endpoint, passing fromDate only when given' do
      stub = stub_api(:get, 'securities-accounts/555/performance')
      client.securities_account_performance(555)
      expect(stub).to have_been_requested

      stub_request(:get, 'https://konto.baaderbank.example/api/securities-accounts/555/performance')
        .with(query: { 'fromDate' => '2026-01-01' })
        .to_return(status: 200, body: '{}')
      client.securities_account_performance(555, from_date: '2026-01-01')
      expect(WebMock).to have_requested(:get, 'https://konto.baaderbank.example/api/securities-accounts/555/performance')
        .with(query: { 'fromDate' => '2026-01-01' })
    end
  end

  describe '#investment_profiles' do
    it 'gets investment-profiles with no query param by default' do
      stub = stub_api(:get, 'securities-accounts/investment-profiles')
      client.investment_profiles
      expect(stub).to have_been_requested
    end

    it 'passes securities-account-number when given' do
      stub_request(:get, 'https://konto.baaderbank.example/api/securities-accounts/investment-profiles')
        .with(query: { 'securities-account-number' => '555' })
        .to_return(status: 200, body: '{}')

      client.investment_profiles(securities_account_number: 555)

      expect(WebMock).to have_requested(:get, 'https://konto.baaderbank.example/api/securities-accounts/investment-profiles')
        .with(query: { 'securities-account-number' => '555' })
    end
  end

  it '#submit_investment_profiles posts to investment-profiles' do
    stub_api(:post, 'securities-accounts/investment-profiles')
    client.submit_investment_profiles({ risk: 'LOW' })
    expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/securities-accounts/investment-profiles')
      .with(body: { risk: 'LOW' }.to_json)
  end

  it '#deposit_mt535 gets the deprecated mt535 endpoint (no v2 replacement documented)' do
    stub = stub_api(:get, 'deposits/555/mt535')
    client.deposit_mt535(555)
    expect(stub).to have_been_requested
  end
end
