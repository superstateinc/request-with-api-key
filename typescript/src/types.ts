export interface QueryParams {
  [key: string]: string | number | boolean | null | undefined;
}

export type RequestMethod = "GET" | "POST" | "PUT" | "DELETE";

export interface SuperstateApiKeyRequest {
  baseUrl?: string;
  apiKey: string;
  apiSecret: string;
  endpoint: string;
  method: RequestMethod;
  queryParams?: QueryParams;
  body?: Record<string, any>;
}

export interface GetTransactionsV2Query extends QueryParams {
  transaction_status?: TransactionStatus;
  from_timestamp?: string; // DateTime<Utc>
  until_timestamp?: string; // DateTime<Utc>
  transaction_hash?: string;
}

export enum TransactionStatus {
  Pending = "Pending",
  Completed = "Completed",
}
