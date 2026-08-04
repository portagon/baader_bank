# frozen_string_literal: true

require "baader_bank"
require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    BaaderBank.configuration = BaaderBank::Configuration.new.tap do |c|
      c.base_url = "https://konto.baaderbank.example/api"
      c.api_key = "test-api-key"
      c.user_id = "test-user"
      c.pin = "123456"
    end
  end
end

def stub_login(access_token: "access-token-1", refresh_token: "refresh-token-1", expires_on: Time.now.to_i + 3600)
  stub_request(:post, "https://konto.baaderbank.example/api/login")
    .to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: {
        access_token: access_token,
        refresh_token: refresh_token,
        token_type: "Bearer",
        expires_on: expires_on
      }.to_json
    )
end
