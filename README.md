# Superstate API Request with API Key

Example repo that explains how to make a request to an endpoint that requires an API key.

## Usage

Copy the `.env.example` file and rename it as `.env`, then fill out the API key and API key secret values that you have received.

Install all required packages and run the script using the following `pnpm` commands (adapt to use `yarn` or `npm` if necessary):

```bash
# Install packages
pnpm install

# Run script
pnpm start
```

This will return all of your transaction data. You may update the `queryParams` to filter the data as necessary. See the example in `src/main.ts`.
