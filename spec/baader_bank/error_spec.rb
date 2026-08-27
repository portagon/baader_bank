# frozen_string_literal: true

RSpec.describe BaaderBank::Error do
  describe '.from_response' do
    it 'maps known status codes to their typed error class' do
      error = described_class.from_response(400, { 'code' => 'BE1001', 'title' => 'Bad input' })

      expect(error).to be_a(BaaderBank::Error::BadRequestError)
      expect(error.code).to eq('BE1001')
      expect(error.title).to eq('Bad input')
    end

    it 'returns nil for success status codes' do
      expect(described_class.from_response(200, {})).to be_nil
      expect(described_class.from_response(202, {})).to be_nil
    end

    it 'returns nil for status codes without a mapped error class' do
      expect(described_class.from_response(999, {})).to be_nil
    end

    it 'tolerates a non-Hash body' do
      error = described_class.from_response(500, 'internal error')

      expect(error).to be_a(BaaderBank::Error::ServerError)
      expect(error.code).to be_nil
    end
  end
end
