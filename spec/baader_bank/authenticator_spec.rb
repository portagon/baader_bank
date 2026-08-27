# frozen_string_literal: true

RSpec.describe BaaderBank::Authenticator do
  subject(:authenticator) { described_class.new(BaaderBank.configuration) }

  describe '#access_token' do
    it 'logs in and returns the access token when nothing is cached' do
      stub_login(access_token: 'fresh-token')

      expect(authenticator.access_token).to eq('fresh-token')
    end

    it 'sends the configured api key, user id and pin' do
      stub_login

      authenticator.access_token

      expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/login')
        .with(
          headers: { 'x-api-key' => 'test-api-key' },
          body: { user_id: 'test-user', pin: '123456' }
        )
    end

    it 'reuses a cached, non-expired token without calling the API again' do
      stub_login(access_token: 'fresh-token', expires_on: Time.now.to_i + 3600)

      2.times { authenticator.access_token }

      expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/login').once
    end

    it 'refreshes an expired token, sending both the refresh token and the stale access token' do
      stub_login(access_token: 'stale-token', refresh_token: 'refresh-token-1', expires_on: Time.now.to_i - 1)
      stub_request(:post, 'https://konto.baaderbank.example/api/token/refresh')
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: { access_token: 'refreshed-token', refresh_token: 'refresh-token-2',
                  expires_on: Time.now.to_i + 3600 }.to_json
        )

      authenticator.access_token # triggers the initial (already-expired) login
      token = authenticator.access_token # triggers refresh

      expect(token).to eq('refreshed-token')
      expect(WebMock).to have_requested(:post, 'https://konto.baaderbank.example/api/token/refresh').with(
        headers: { 'Authorization' => 'Bearer stale-token' },
        body: { grant_type: 'refresh_token', refresh_token: 'refresh-token-1' }
      )
    end

    it 'falls back to a fresh login when refreshing fails' do
      second_login_body = { access_token: 'second-login-token', refresh_token: 'r2',
                            expires_on: Time.now.to_i + 3600 }.to_json
      stub_login(access_token: 'stale-token', expires_on: Time.now.to_i - 1)
        .then.to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: second_login_body)

      refresh_error_body = { status: 401, code: 'BE1401', title: 'Invalid refresh token' }.to_json
      stub_request(:post, 'https://konto.baaderbank.example/api/token/refresh')
        .to_return(status: 401, headers: { 'Content-Type' => 'application/json' }, body: refresh_error_body)

      authenticator.access_token
      token = authenticator.access_token

      expect(token).to eq('second-login-token')
    end

    it 'raises a typed error when login itself fails' do
      stub_request(:post, 'https://konto.baaderbank.example/api/login')
        .to_return(status: 401, headers: { 'Content-Type' => 'application/json' },
                   body: { status: 401, code: 'BE1001', title: 'Invalid credentials' }.to_json)

      expect { authenticator.access_token }.to raise_error(BaaderBank::Error::UnauthorizedError, /Invalid credentials/)
    end
  end
end

RSpec.describe BaaderBank::Authenticator::MemoryTokenStore do
  subject(:store) { described_class.new }

  it 'returns nil before anything has been written' do
    expect(store.read).to be_nil
  end

  it 'returns the last-written token' do
    store.write({ access_token: 'a', refresh_token: 'b', expires_on: 123 })

    expect(store.read).to eq({ access_token: 'a', refresh_token: 'b', expires_on: 123 })
  end
end
