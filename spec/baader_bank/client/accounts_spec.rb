# frozen_string_literal: true

require 'tempfile'

RSpec.describe BaaderBank::Client::Accounts do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  def with_zip
    Tempfile.create(['doc', '.zip']) do |file|
      file.write('fake zip content')
      file.rewind
      yield file.path
    end
  end

  describe '#upload_opening_documents' do
    it 'posts to v2/accounts/upload/opening with customerId, accountType and minute-precision datetime' do
      stub_request(:post, 'https://konto.baaderbank.example/api/v2/accounts/upload/opening').to_return(status: 202)

      with_zip do |path|
        client.upload_opening_documents(path, customer_id: 42, account_type: 'INDIVIDUAL',
                                              document_date_time: Time.utc(2026, 1, 2, 3, 4, 5))
      end

      expect(WebMock).to(have_requested(:post, 'https://konto.baaderbank.example/api/v2/accounts/upload/opening')
        .with { |r| r.body.include?('name="customerId"') && r.body.include?('42') })
      expect(WebMock).to(have_requested(:post, 'https://konto.baaderbank.example/api/v2/accounts/upload/opening')
        .with { |r| r.body.include?('2026-01-02T03:04') && !r.body.include?('03:04:05') })
    end

    it 'includes portfolioNumber and currency only when given' do
      stub_request(:post, 'https://konto.baaderbank.example/api/v2/accounts/upload/opening').to_return(status: 202)

      with_zip do |path|
        client.upload_opening_documents(path, customer_id: 42, account_type: 'CURRENCY',
                                              portfolio_number: 3, currency: 'EUR')
      end

      expect(WebMock).to(have_requested(:post, 'https://konto.baaderbank.example/api/v2/accounts/upload/opening')
        .with { |r| r.body.include?('name="portfolioNumber"') && r.body.include?('name="currency"') })
    end
  end

  describe '#upload_closing_documents' do
    it 'posts to accounts/upload/closing with the customer id' do
      stub_request(:post, 'https://konto.baaderbank.example/api/accounts/upload/closing').to_return(status: 202)

      with_zip { |path| client.upload_closing_documents(path, customer_id: 7) }

      expect(WebMock).to(have_requested(:post, 'https://konto.baaderbank.example/api/accounts/upload/closing')
        .with { |r| r.body.include?('7') })
    end
  end

  describe '#upload_changing_documents' do
    it 'posts to accounts/upload/changing with the modified attribute' do
      stub_request(:post, 'https://konto.baaderbank.example/api/accounts/upload/changing').to_return(status: 202)

      with_zip { |path| client.upload_changing_documents(path, customer_id: 7, modified_attribute: 'ADDRESS') }

      expect(WebMock).to(have_requested(:post, 'https://konto.baaderbank.example/api/accounts/upload/changing')
        .with { |r| r.body.include?('name="modifiedAttribute"') && r.body.include?('ADDRESS') })
    end
  end

  describe '#account_balance' do
    it 'gets accounts/:number/balance' do
      stub = stub_api(:get, 'accounts/12345/balance')

      client.account_balance('12345')

      expect(stub).to have_been_requested
    end
  end

  describe '#account_transactions' do
    it 'gets accounts/:number/transactions with no query params by default' do
      stub = stub_api(:get, 'accounts/12345/transactions')

      client.account_transactions('12345')

      expect(stub).to have_been_requested
    end

    it 'passes booking-date and transaction-number-greater-than as query params when given' do
      stub_request(:get, 'https://konto.baaderbank.example/api/accounts/12345/transactions')
        .with(query: { 'booking-date' => '2026-01-01', 'transaction-number-greater-than' => '10' })
        .to_return(status: 200, body: '{}')

      client.account_transactions('12345', booking_date: '2026-01-01', transaction_number_greater_than: '10')

      expect(WebMock).to have_requested(:get, 'https://konto.baaderbank.example/api/accounts/12345/transactions')
        .with(query: { 'booking-date' => '2026-01-01', 'transaction-number-greater-than' => '10' })
    end
  end
end
