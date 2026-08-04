# frozen_string_literal: true

RSpec.describe BaaderBank::Client::Customer do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it "#customer falls back to the deprecated v1 endpoint (no v2 replacement documented)" do
    stub = stub_api(:get, "customers/1")
    client.customer(1)
    expect(stub).to have_been_requested
  end

  it "#end_customer gets customers/endcustomer/:id" do
    stub = stub_api(:get, "customers/endcustomer/1")
    client.end_customer(1)
    expect(stub).to have_been_requested
  end

  it "#customer_relationships gets the v2 endpoint" do
    stub = stub_api(:get, "v2/customers/relationships/1")
    client.customer_relationships(1)
    expect(stub).to have_been_requested
  end

  it "#customer_reference_accounts gets the v2 endpoint" do
    stub = stub_api(:get, "v2/customers/1/referenceaccounts")
    client.customer_reference_accounts(1)
    expect(stub).to have_been_requested
  end

  it "#customer_locks gets the v2 endpoint" do
    stub = stub_api(:get, "v2/customers/1/locks")
    client.customer_locks(1)
    expect(stub).to have_been_requested
  end

  it "#customer_balance gets the (v1-only) balance endpoint" do
    stub = stub_api(:get, "customers/1/balance")
    client.customer_balance(1)
    expect(stub).to have_been_requested
  end

  describe "#customer_intraday_payments" do
    it "gets the v2 endpoint with no query param by default" do
      stub = stub_api(:get, "v2/customers/1/intraday-payments")
      client.customer_intraday_payments(1)
      expect(stub).to have_been_requested
    end

    it "passes booking-date when given" do
      stub_request(:get, "https://konto.baaderbank.example/api/v2/customers/1/intraday-payments")
        .with(query: { "booking-date" => "2026-01-01" })
        .to_return(status: 200, body: "{}")

      client.customer_intraday_payments(1, booking_date: "2026-01-01")

      expect(WebMock).to have_requested(:get, "https://konto.baaderbank.example/api/v2/customers/1/intraday-payments")
        .with(query: { "booking-date" => "2026-01-01" })
    end
  end

  it "#customer_intraday_account_openings gets the v2 endpoint" do
    stub = stub_api(:get, "v2/customers/1/intraday-account-openings")
    client.customer_intraday_account_openings(1)
    expect(stub).to have_been_requested
  end

  it "#customer_interday_payments falls back to the v1-only endpoint (no v2 replacement documented)" do
    stub = stub_api(:get, "customers/1/interday-payments")
    client.customer_interday_payments(1)
    expect(stub).to have_been_requested
  end

  it "#customer_interday_account_openings falls back to the v1-only endpoint" do
    stub = stub_api(:get, "customers/1/interday-account-openings")
    client.customer_interday_account_openings(1)
    expect(stub).to have_been_requested
  end
end
