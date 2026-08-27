# frozen_string_literal: true

RSpec.describe BaaderBank::Client::Tax do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it '#tax_master_data gets the v2 endpoint' do
    stub = stub_api(:get, 'v2/tax/1/tax-master-data')
    client.tax_master_data(1)
    expect(stub).to have_been_requested
  end
end
