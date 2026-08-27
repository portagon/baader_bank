# frozen_string_literal: true

require 'tempfile'

RSpec.describe BaaderBank::Client::Orders do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  describe '#upload_order_documents' do
    it 'posts to orders/upload/ordering and accepts a plain IO instead of a path' do
      stub_request(:post, 'https://konto.baaderbank.example/api/orders/upload/ordering').to_return(status: 202)

      client.upload_order_documents(StringIO.new('fake zip content'), document_date_time: Time.utc(2026, 1, 2, 3, 4))

      expect(WebMock).to(have_requested(:post, 'https://konto.baaderbank.example/api/orders/upload/ordering')
        .with { |request| request.body.include?('2026-01-02T03:04:00.000') })
    end

    it 'defaults documentDateTime to the current time when not given' do
      stub_request(:post, 'https://konto.baaderbank.example/api/orders/upload/ordering').to_return(status: 202)

      client.upload_order_documents(StringIO.new('fake zip content'))

      expect(WebMock).to(have_requested(:post, 'https://konto.baaderbank.example/api/orders/upload/ordering')
        .with { |request| request.body.include?('name="documentDateTime"') })
    end
  end
end
