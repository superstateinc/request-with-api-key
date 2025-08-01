import { superstateApiKeyRequest } from "./";
// eslint-disable-next-line @typescript-eslint/no-unused-vars
import { TransactionStatus } from "./types";
import dotenv from "dotenv";
dotenv.config();

export const TRANSACTIONS_ENDPOINT = `v2/transactions`;

// The API key and secret are set in the .env file. You should have received a keypair from the
// Superstate team. If you need a new API keypair, please reach out to the Superstate team.
export const SUPERSTATE_API_KEY = process.env.SUPERSTATE_API_KEY || "";
export const SUPERSTATE_API_SECRET = process.env.SUPERSTATE_API_SECRET || "";

if (SUPERSTATE_API_KEY === "" || SUPERSTATE_API_SECRET === "") {
  throw new Error("SUPERSTATE_API_KEY and SUPERSTATE_API_SECRET must be set");
}

async function main() {
  // You can insert queryParams into this request to filter transactions. The body must remain an
  // empty object since it is a GET request. Example queryParams:
  //   queryParams: {
  //     transaction_status: TransactionStatus.Pending,
  //     from_timestamp: "2024-07-22T00:00:00.000Z",
  //     until_timestamp: "2024-07-23T00:00:00.000Z",
  //   },
  const transactions = await superstateApiKeyRequest({
    apiKey: SUPERSTATE_API_KEY,
    apiSecret: SUPERSTATE_API_SECRET,
    endpoint: TRANSACTIONS_ENDPOINT,
    method: "GET",
    queryParams: {},
    body: {},
  });

  console.log(transactions);
}

main();
