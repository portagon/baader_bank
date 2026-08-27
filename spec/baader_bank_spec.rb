# frozen_string_literal: true

RSpec.describe BaaderBank do
  it 'has a version number' do
    expect(BaaderBank::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'yields a shared Configuration instance' do
      described_class.configure { |c| c.api_key = 'test-key' }

      expect(described_class.configuration.api_key).to eq('test-key')
    end
  end
end
