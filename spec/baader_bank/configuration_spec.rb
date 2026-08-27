# frozen_string_literal: true

RSpec.describe BaaderBank::Configuration do
  subject(:configuration) { described_class.new }

  describe '#base_url' do
    it 'defaults to the production API with a trailing slash' do
      expect(configuration.base_url).to eq('https://konto.baaderbank.de/api/')
    end

    it 'appends a trailing slash when one is missing, so relative resource paths resolve under it' do
      configuration.base_url = 'https://konto.baaderbank.example/api'

      expect(configuration.base_url).to eq('https://konto.baaderbank.example/api/')
    end

    it 'leaves a base URL that already has a trailing slash unchanged' do
      configuration.base_url = 'https://konto.baaderbank.example/api/'

      expect(configuration.base_url).to eq('https://konto.baaderbank.example/api/')
    end
  end

  describe '#token_store' do
    it 'defaults to nil, letting Authenticator fall back to MemoryTokenStore' do
      expect(configuration.token_store).to be_nil
    end
  end
end
