# frozen_string_literal: true

require "tempfile"

RSpec.describe BaaderBank::Client do
  subject(:client) { described_class.new(BaaderBank.configuration) }

  before { stub_login }

  describe "#get" do
    it "sends the bearer token and returns the parsed JSON body" do
      stub_request(:get, "https://konto.baaderbank.example/api/accounts/12345/balance")
        .to_return(status: 200, headers: { "Content-Type" => "application/json" },
                   body: { balance: "1000.00", currency: "EUR" }.to_json)

      result = client.account_balance("12345")

      expect(result).to eq({ "balance" => "1000.00", "currency" => "EUR" })
      expect(WebMock).to have_requested(:get, "https://konto.baaderbank.example/api/accounts/12345/balance")
        .with(headers: { "Authorization" => "Bearer access-token-1" })
    end

    it "raises a typed error for a non-2xx response" do
      stub_request(:get, "https://konto.baaderbank.example/api/accounts/12345/balance")
        .to_return(status: 404, headers: { "Content-Type" => "application/json" },
                   body: { status: 404, code: "BE2001", title: "Account not found" }.to_json)

      expect { client.account_balance("12345") }.to raise_error(BaaderBank::Error::NotFoundError, /Account not found/)
    end
  end

  describe "#post_multipart" do
    it "uploads the file with a computed checksum and the given fields" do
      stub_request(:post, "https://konto.baaderbank.example/api/orders/upload/ordering")
        .to_return(status: 202)

      Tempfile.create(["order", ".zip"]) do |file|
        file.write("fake zip content")
        file.rewind

        client.upload_order_documents(file.path, document_date_time: Time.utc(2026, 8, 4, 8, 0, 0))
      end

      expect(WebMock).to(have_requested(:post, "https://konto.baaderbank.example/api/orders/upload/ordering")
        .with { |request| request.body.include?('name="checksumSha256"') })
      expect(WebMock).to(have_requested(:post, "https://konto.baaderbank.example/api/orders/upload/ordering")
        .with { |request| request.body.include?("2026-08-04T08:00:00.000") })
    end
  end

  describe "#post_xml" do
    it "sends the raw XML body with an XML content type, unmodified by JSON encoding" do
      xml = "<Document><CstmrCdtTrfInitn/></Document>"
      stub_request(:post, "https://konto.baaderbank.example/api/payments/sepa-credit-transfer")
        .with(body: xml, headers: { "Content-Type" => "application/xml" })
        .to_return(status: 202)

      client.sepa_credit_transfer(xml)

      expect(WebMock).to have_requested(:post, "https://konto.baaderbank.example/api/payments/sepa-credit-transfer")
        .with(body: xml)
    end
  end

  describe "#put" do
    it "sends a JSON body and returns the parsed response" do
      stub_api(:put, "some/path", body: { updated: true })

      result = client.put("some/path", { name: "changed" })

      expect(result).to eq({ "updated" => true })
      expect(WebMock).to have_requested(:put, "https://konto.baaderbank.example/api/some/path")
        .with(body: { name: "changed" }.to_json)
    end
  end

  describe "#delete" do
    it "sends the request and returns the parsed response" do
      stub_api(:delete, "some/path", status: 200, body: {})

      client.delete("some/path")

      expect(WebMock).to have_requested(:delete, "https://konto.baaderbank.example/api/some/path")
    end
  end

  describe "network-level failures" do
    it "wraps a connection failure in an untyped Error carrying the underlying message" do
      stub_request(:get, "https://konto.baaderbank.example/api/accounts/12345/balance")
        .to_raise(Faraday::ConnectionFailed.new("Connection refused"))

      expect { client.account_balance("12345") }.to raise_error(BaaderBank::Error) do |error|
        expect(error).not_to be_a(BaaderBank::Error::ServerError) # no HTTP response to classify by
        expect(error.status).to be_nil
        expect(error.message).to include("Connection refused")
      end
    end
  end
end
