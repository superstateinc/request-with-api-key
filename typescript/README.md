# @superstateinc/api-key-request

This package provides a simple way to make requests to Superstate API endpoints that are protected by an API key.

## Quickstart

Install the package using npm (or your favorite package manager):

```bash
npm install @superstateinc/api-key-request
```

Use the package in your code:

```typescript
import { superstateApiKeyRequest, TransactionStatus } from '@superstateinc/api-key-request';

const transactions = await superstateApiKeyRequest({
  apiKey: SUPERSTATE_API_KEY,
  apiSecret: SUPERSTATE_API_SECRET,
  endpoint: "v2/transactions",
  method: "GET",
  queryParams: {
    transaction_status: TransactionStatus.Pending
  },
});

console.log(transactions);
```

## Manually creating a request

The package automatically builds the required headers for you, but manually building the headers is also possible, if you would prefer to do it yourself.

### Building the header

The following headers are required for all requests that are protected by an API key:

- `X-Nonce: <nonce>`: a randomly-generated UUID
- `X-Timestamp: <epoch_timestamp_ms>`: the epoch timestamp in milliseconds
- `X-Params-Hash: <path and query params hashed>`: path and query params are parsed and normalized into a single string and hashed as follows:
  - Path params are normalized to include leading slash and remove trailing slash (`https://api.example.com/v2/table/cells/9/` becomes `/v2/table/cells/9`)
  - Query params are sorted alphabetically by key, then by value if any are repeated, and url encoded (`?z=10&name=Bob Joe` becomes `?name=Bob%20Joe&z=10`)
  - Combined: `/v2/table/cells/9?id=341&name=Bob Joe&enabled=true` becomes `/v2/table/cells/9?enabled=true&id=341&name=Bob%20Joe` which is then hashed with SHA256
- `X-Body-Hash: <body serialized and hashed>`: body of the request is serialized then SHA256-hashed. If the request has no body (such as GET or DELETE), then this should be SHA256("")
- `X-Hmac: <HMAC-SHA256(api_secret, api_key + epoch_timestamp_ms + nonce + params_hash + body_hash)>`: generates an HMAC (Hash-based Message Authentication Code) to allow validation of authenticity and integrity of the message; encoded as standard base64 string. `+` denotes string concatenation.
- `Authorization: Bearer <api_key>`: the API key in plaintext.

### Authentication Flow

The nonce, timestamp, and hash are used to prevent replay attacks. The system works like so: when generating a request, the client will generate a random UUID to be used as a nonce. The user adds in their API secret which was generated with the API key to generate the HMAC via `HMAC-SHA256(api_secret, api_key + epoch_timestamp_ms + nonce + params_hash + body_hash)` and includes it in the request header.
