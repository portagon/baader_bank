# BaaderBank

A Ruby client for the [Baader Bank Customer REST API](https://konto.baaderbank.de/apidoc/), encapsulating
authentication, error handling, and resource methods (accounts, orders, securities accounts, payments, and
related resources) behind a single `BaaderBank::Client`.

This gem exists to replace `skynet`'s current SFTP/form-POST-based Baader Bank integration with the documented
REST API. See `skynet`'s `docs/BAADER_BANK_*.md` for the current (pre-migration) architecture.

## Installation

Not yet published to a gem server. Point at this repo directly from the consuming app's Gemfile:

```ruby
gem "baader_bank", git: "https://github.com/portagon/baader_bank", branch: "main"
```

## Usage

Configure once, e.g. from a Rails initializer:

```ruby
BaaderBank.configure do |config|
  config.base_url = "https://konto.baaderbank.de/api" # or the sandbox URL once Baader provides one
  config.api_key   = Rails.application.credentials.baader_bank[:api_key]
  config.user_id   = Rails.application.credentials.baader_bank[:client_user_id]
  config.pin       = Rails.application.credentials.baader_bank[:client_pin]
end
```

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
  Honeybadger.notify(e, context: { baader_code: e.code, baader_title: e.title })
end
```

### Authentication

Login (`POST /login`) and token refresh (`POST /token/refresh`) are handled transparently by
`BaaderBank::Authenticator` - every resource call gets a valid bearer token, refreshing or re-logging in as
needed. By default tokens are cached in-process only (`Authenticator::MemoryTokenStore`), which is fine for a
single long-lived process but **not** shared across multiple dynos/workers. To share a token across processes,
inject a store that responds to `#read` and `#write(token)`, e.g. backed by `Rails.cache`:

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

### Uploading documents (replacing SFTP)

`upload_order_documents`, `upload_opening_documents`, `upload_closing_documents`, and `upload_changing_documents`
all take a file path or IO plus a `document_date_time:`, multipart-POST the ZIP, and compute the required
`checksumSha256` automatically. A `202` response confirms receipt only - it is not the same guarantee as the old
SFTP `.ok` file plus daily CSV reconciliation, since Baader hasn't documented whether `202` implies successful
downstream processing.

## Known gaps / open questions for Baader

These are tracked because the OpenAPI spec (v2.5.0) doesn't fully answer them - see the module-level comments
in `lib/baader_bank/client/*.rb` for where each one matters:

- No sandbox/test server is listed (only `Produktion`) - already raised with Baader in the 2026-08 migration call.
- `GET /asset-manager/files/{file-type}` uses a `CSV1/2/3/N/K` + `PDF1/2/3/N` enum not yet mapped to the legacy
  record types (RKK/WDP/WUM/AKS/AEA) the current SFTP-era parsers expect.
- `POST /orders/upload/ordering` doesn't document how Baader distinguishes a block-order ZIP from a breakdown ZIP.
- The documented access-token lifetime is inconsistent between the security scheme (60 min) and the refresh
  endpoint description (5 min) - `Authenticator` doesn't assume either and always trusts the response's
  `expires_on`.
- `POST /token/refresh` requires the *expired* access token as a Bearer header **and** the refresh token in the
  body (per the spec's `security` requirement on that endpoint) - implemented, but unverified against a live API.
- Several endpoints (`interday-payments`, `interday-account-openings` on Customer/Asset-Managers, the base
  `GET /customers/{id}`, `GET /deposits/{securities-account}/mt535`) only exist as `deprecated: true` with no
  documented `v2` replacement - implemented as-is since there's no alternative, flagged in code comments.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run `bundle exec rspec` to run the
tests (WebMock-stubbed, no network access) and `bundle exec rubocop` for style. `bin/console` gives an
interactive prompt for experimentation.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/portagon/baader_bank.
