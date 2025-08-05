# SuperstateApiKeyRequest

[![Hex.pm](https://img.shields.io/hexpm/v/superstate_api_key_request.svg)](https://hex.pm/packages/superstate_api_key_request)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/superstate_api_key_request)

Make an API request to a Superstate endpoint that requires an API key.

This Elixir package provides functionality to authenticate and make HTTP requests to Superstate API endpoints using API key authentication with HMAC signing.

## Installation

Add `superstate_api_key_request` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:superstate_api_key_request, "~> 0.1.4"}
  ]
end
```

## Usage

### Basic Usage

```elixir
# Make a simple GET request to fetch transactions
{:ok, transactions} = SuperstateApiKeyRequest.request(%{
  api_key: "your_api_key",
  api_secret: "your_api_secret",
  endpoint: "v2/transactions",
  method: :get,
  query_params: %{},
  body: %{}
})
```

### Using Environment Variables

Set your API credentials as environment variables:

```bash
export SUPERSTATE_API_KEY="your_api_key"
export SUPERSTATE_API_SECRET="your_api_secret"
```

Then use the example module:

```elixir
# Fetch all transactions
{:ok, transactions} = SuperstateApiKeyRequest.Example.fetch_transactions()

# Fetch only pending transactions
{:ok, pending} = SuperstateApiKeyRequest.Example.fetch_pending_transactions()

# Fetch transactions by date range
{:ok, filtered} = SuperstateApiKeyRequest.Example.fetch_transactions_by_date_range(
  "2024-07-22T00:00:00.000Z",
  "2024-07-23T00:00:00.000Z"
)
```

### Advanced Usage with Query Parameters

```elixir
alias SuperstateApiKeyRequest.Types.TransactionStatus

# Fetch transactions with filters
{:ok, transactions} = SuperstateApiKeyRequest.request(%{
  api_key: "your_api_key",
  api_secret: "your_api_secret",
  endpoint: "v2/transactions",
  method: :get,
  query_params: %{
    "transaction_status" => TransactionStatus.pending(),
    "from_timestamp" => "2024-07-22T00:00:00.000Z",
    "until_timestamp" => "2024-07-23T00:00:00.000Z"
  },
  body: %{}
})
```

## Configuration

You can configure the default base URL in your `config.exs`:

```elixir
config :superstate_api_key_request,
  default_base_url: "https://api.superstate.com"
```

## API Reference

### SuperstateApiKeyRequest.request/1

Makes an authenticated API request to a Superstate endpoint.

**Parameters:**
- `options` - A map containing:
  - `:base_url` - Base URL for the API (optional, defaults to "https://api.superstate.com")
  - `:api_key` - Your Superstate API key (required)
  - `:api_secret` - Your Superstate API secret (required)
  - `:endpoint` - The API endpoint to call (required)
  - `:method` - HTTP method (`:get`, `:post`, `:put`, `:delete`) (required)
  - `:query_params` - Map of query parameters (optional)
  - `:body` - Request body as a map (optional)

**Returns:**
- `{:ok, response}` - On successful request
- `{:error, reason}` - On failure

## Authentication

This package implements the Superstate API authentication scheme:

1. Generates a unique nonce for each request
2. Creates a timestamp
3. Computes hashes of query parameters and request body
4. Creates an HMAC signature using the API secret
5. Includes all authentication headers in the request

The authentication headers include:
- `Authorization: Bearer <api_key>`
- `X-Nonce: <nonce>`
- `X-Timestamp: <timestamp>`
- `X-Params-Hash: <params_hash>`
- `X-Body-Hash: <body_hash>`
- `X-Hmac: <hmac_signature>`

## Types

The package includes type definitions in `SuperstateApiKeyRequest.Types`:

- `TransactionStatus` - Enum for transaction status values
- Type specifications for request configuration and query parameters

## Testing

Run the test suite:

```bash
mix test
```

## Publishing to Hex

This package is configured for publishing to Hex.pm. To publish:

1. Ensure all tests pass: `mix test`
2. Update the version in `mix.exs`
3. Create a git tag: `git tag v0.1.4`
4. Publish: `mix hex.publish`

## License

ISC

## Changelog

### 0.1.4
- Initial Elixir port from TypeScript package
- Support for authenticated API requests with HMAC signing
- Example usage patterns
- Comprehensive documentation