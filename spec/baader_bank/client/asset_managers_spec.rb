# frozen_string_literal: true

RSpec.describe BaaderBank::Client::AssetManagers do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it '#asset_manager gets v2/asset-manager/:id' do
    stub = stub_api(:get, 'v2/asset-manager/99')
    client.asset_manager(99)
    expect(stub).to have_been_requested
  end

  it '#asset_manager_balance gets v2/asset-manager/:id/balance' do
    stub = stub_api(:get, 'v2/asset-manager/99/balance')
    client.asset_manager_balance(99)
    expect(stub).to have_been_requested
  end

  it '#asset_manager_closed_info gets v2/asset-manager/:id/closed-info' do
    stub = stub_api(:get, 'v2/asset-manager/99/closed-info')
    client.asset_manager_closed_info(99)
    expect(stub).to have_been_requested
  end

  it '#asset_manager_intraday_payments gets the v2 endpoint' do
    stub = stub_api(:get, 'v2/asset-manager/99/intraday-payments')
    client.asset_manager_intraday_payments(99)
    expect(stub).to have_been_requested
  end

  it '#asset_manager_intraday_account_openings gets the v2 endpoint' do
    stub = stub_api(:get, 'v2/asset-manager/99/intraday-account-openings')
    client.asset_manager_intraday_account_openings(99)
    expect(stub).to have_been_requested
  end

  it '#asset_manager_interday_payments falls back to the deprecated v1 endpoint (no v2 replacement exists)' do
    stub = stub_api(:get, 'asset-manager/99/interday-payments')
    client.asset_manager_interday_payments(99)
    expect(stub).to have_been_requested
  end

  it '#asset_manager_interday_account_openings falls back to the deprecated v1 endpoint' do
    stub = stub_api(:get, 'asset-manager/99/interday-account-openings')
    client.asset_manager_interday_account_openings(99)
    expect(stub).to have_been_requested
  end

  describe '#zip_file_download_url' do
    it 'gets v2/asset-manager/files/:file-type without a date param by default' do
      stub_request(:get, 'https://konto.baaderbank.example/api/v2/asset-manager/files/CSV1')
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: '"https://example.com/f"')

      result = client.zip_file_download_url('CSV1')

      expect(result).to eq('https://example.com/f')
    end

    it 'passes file-date as a query param when given' do
      stub_request(:get, 'https://konto.baaderbank.example/api/v2/asset-manager/files/CSV1')
        .with(query: { 'file-date' => '2026-01-01' })
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: '"url"')

      client.zip_file_download_url('CSV1', file_date: '2026-01-01')

      expect(WebMock).to have_requested(:get, 'https://konto.baaderbank.example/api/v2/asset-manager/files/CSV1')
        .with(query: { 'file-date' => '2026-01-01' })
    end

    it 'exposes the documented file-type enum for callers to validate against' do
      expect(described_class::FILE_TYPES).to contain_exactly(
        'PDF1', 'PDF2', 'PDF3', 'PDFN', 'CSV1', 'CSV2', 'CSV3', 'CSVN', 'CSVK'
      )
    end
  end
end
