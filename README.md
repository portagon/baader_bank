# Baader Bank

> [!WARNING]
> **Pre-release:** Features and APIs may change, and breaking changes may occur before the first stable release.

A Ruby client for the [Baader Bank Customer REST API](https://konto.baaderbank.de/apidoc/). It provides
authentication, token refresh, typed error handling, document uploads, and resource methods for accounts,
orders, securities accounts, payments, and related endpoints through a single `BaaderBank::Client`.

## Installation

Add the gem to your `Gemfile`:

```ruby
source 'https://rubygems.pkg.github.com/portagon' do
  gem 'baader_bank'
end
```

To use the latest code directly from the repository instead, use the Git source:

```ruby
gem 'baader_bank', git: 'https://github.com/portagon/baader_bank', branch: 'main'
```

## Usage

Configure the client once, for example in a Rails initializer:

```ruby
BaaderBank.configure do |config|
  config.base_url = "https://konto.baaderbank.de/api"
  config.api_key   = Rails.application.credentials.baader_bank[:api_key]
  config.user_id   = Rails.application.credentials.baader_bank[:client_user_id]
  config.pin       = Rails.application.credentials.baader_bank[:client_pin]
  config.proxy     = ENV["BAADER_BANK_PROXY"] # optional, e.g. http://user:password@proxy.example:8080
end
```

The proxy is optional and applies to login, token refresh, and all resource requests. It accepts any
Faraday-compatible proxy value, including a URL string or an options hash.

Then obtain a client and call resource methods:

```ruby
client = BaaderBank.client

client.account_balance("12345678")
client.upload_order_documents("tmp/order_2026-08-04.zip", document_date_time: Time.current)
client.zip_file_download_url("CSV1", file_date: Date.yesterday)
```

Every method raises a typed `BaaderBank::Error` subclass (`BadRequestError`, `UnauthorizedError`,
`NotFoundError`, `ConflictError`, `ServerError`, `ServiceUnavailableError`, ...) on a non-2xx response, carrying
the API's `code`/`title`/`detail` fields:

```ruby
begin
  client.account_balance("does-not-exist")
rescue BaaderBank::Error::NotFoundError => e
  logger.error("Baader Bank request failed: #{e.code} - #{e.title}")
end
```

### Authentication

Login (`POST /login`) and token refresh (`POST /token/refresh`) are handled transparently by
`BaaderBank::Authenticator` - every resource call gets a valid bearer token, refreshing or re-logging in as
needed. By default, tokens are cached in-process using `Authenticator::MemoryTokenStore`. Applications running
multiple processes or instances should inject a shared store that responds to `#read` and `#write(token)`, for
example one backed by `Rails.cache`:

```ruby
class RailsCacheTokenStore
  KEY = "baader_bank:token"

  def read
    Rails.cache.read(KEY)
  end

  def write(token)
    Rails.cache.write(KEY, token)
  end
end

BaaderBank.configure { |c| c.token_store = RailsCacheTokenStore.new }
```

### Uploading documents

`upload_order_documents`, `upload_opening_documents`, `upload_closing_documents`, and `upload_changing_documents`
all take a file path or IO plus a `document_date_time:`, multipart-POST the ZIP, and compute the required
`checksumSha256` automatically. A `202` response confirms that the request was accepted; applications should
verify downstream processing separately when their workflow requires it.

## API notes and limitations

The published OpenAPI specification (v2.5.0) leaves some behavior unspecified. Relevant implementation details
are also documented in `lib/baader_bank/client/*.rb`:

- The API documentation lists only the production server and does not currently identify a sandbox endpoint.
- `GET /asset-manager/files/{file-type}` uses the `CSV1/2/3/N/K` and `PDF1/2/3/N` file-type values without
  describing their business-level contents.
- `POST /orders/upload/ordering` doesn't document how Baader distinguishes a block-order ZIP from a breakdown ZIP.
- The documented access-token lifetime is inconsistent between the security scheme (60 min) and the refresh
  endpoint description (5 min) - `Authenticator` doesn't assume either and always trusts the response's
  `expires_on`.
- `POST /token/refresh` requires the *expired* access token as a Bearer header **and** the refresh token in the
  body, following the endpoint's published security requirements.
- Several endpoints (`interday-payments`, `interday-account-openings` on Customer/Asset-Managers, the base
  `GET /customers/{id}`, `GET /deposits/{securities-account}/mt535`) only exist as `deprecated: true` with no
  documented `v2` replacement. The client keeps these endpoints available and flags them in code comments.

## Development

After checking out the repository, run `bin/setup` to install dependencies. Run `bundle exec rake` to execute
the WebMock-backed test suite and RuboCop checks. No live API access is required. Use `bin/console` for an
interactive prompt.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/portagon/baader_bank).
