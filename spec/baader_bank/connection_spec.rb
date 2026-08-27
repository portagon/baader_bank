# frozen_string_literal: true

RSpec.describe BaaderBank::Connection do
  describe '.build' do
    it 'configures the Faraday connection with the configured proxy' do
      configuration = BaaderBank::Configuration.new
      configuration.proxy = 'http://proxy-user:proxy-password@proxy.example:8080'

      connection = described_class.build(configuration)

      expect(connection.proxy.uri.host).to eq('proxy.example')
      expect(connection.proxy.uri.port).to eq(8080)
      expect(connection.proxy.user).to eq('proxy-user')
      expect(connection.proxy.password).to eq('proxy-password')
    end
  end
end
