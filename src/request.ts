import crypto from "crypto";
import { v4 as uuidv4 } from "uuid";
import { QueryParams, SuperstateApiKeyRequest } from "./types";

const DEFAULT_BASE_URL = "https://api.superstate.com";

export async function superstateApiKeyRequest({
  baseUrl = DEFAULT_BASE_URL,
  apiKey,
  apiSecret,
  endpoint,
  method,
  queryParams = {},
  body = {},
}: SuperstateApiKeyRequest) {
  if (!endpoint) {
    throw new Error("endpoint is required");
  }
  if (endpoint.startsWith("/")) {
    endpoint = endpoint.substring(1);
  }

  const headers = buildHeaders(endpoint, apiKey, apiSecret, queryParams, body);

  // Construct URL with query parameters
  const url = new URL(`${baseUrl}/${endpoint}`);
  Object.entries(queryParams).forEach(([key, value]) => {
    url.searchParams.append(key, String(value));
  });

  const response = await fetch(url.toString(), {
    method,
    headers,
    ...(!["GET", "HEAD", "DELETE", "OPTIONS"].includes(method) && {
      body: JSON.stringify(body),
    }),
  });

  if (!response.ok) {
    throw new Error(
      `Request failed with status ${response.status}: ${await response.text()}`
    );
  }

  const data = await response.json();
  return data;
}

function buildHeaders(
  endpoint: string,
  apiKey: string,
  apiSecret: string,
  queryParams: Record<string, any>,
  body: Record<string, any>
) {
  const nonce = uuidv4();
  const timestamp = Date.now().toString();
  const paramsHash = getParamsHash(endpoint, queryParams);
  const bodyHash = getBodyHash(body);
  const message = `${apiKey}${nonce}${timestamp}${paramsHash}${bodyHash}`;
  const hmac = crypto
    .createHmac("sha256", apiSecret)
    .update(message)
    .digest("base64");

  const superstateHeaders = {
    Authorization: `Bearer ${apiKey}`,
    "X-Nonce": nonce,
    "X-Timestamp": timestamp,
    "X-Params-Hash": paramsHash,
    "X-Body-Hash": bodyHash,
    "X-Hmac": hmac,
  };

  const appHeaders = {
    "Content-Type": "application/json",
  };

  const headers = new Headers();
  Object.entries({ ...superstateHeaders, ...appHeaders }).forEach(
    ([key, value]) => headers.append(key, String(value))
  );

  return headers;
}

// Sorts the query params alphabetically, appends them to the path, and hashes the result
function getParamsHash(path: string, query: QueryParams) {
  // Ensure leading slash, remove trailing slash
  path = path.replace(/\/+$/, "");
  path = path.startsWith("/") ? path : `/${path}`;

  let paramsString = path;
  if (Object.keys(query).length > 0) {
    let queryParams = new URLSearchParams(sortKeys(query));
    paramsString += `?${queryParams.toString()}`;
  }

  const paramsHash = crypto
    .createHash("sha256")
    .update(paramsString)
    .digest("hex");
  return paramsHash;
}

// JSON-encodes the body, sorts the keys alphabetically, and hashes the result
function getBodyHash(body: Record<string, any>) {
  // Convert the body to raw bytes using TextEncoder
  const encoder = new TextEncoder();
  const bodyString = JSON.stringify(sortKeys(body));
  const bodyBytes = encoder.encode(bodyString);
  const bodyHash = crypto.createHash("sha256").update(bodyBytes).digest("hex");
  return bodyHash;
}

// Keys of the query params and body must be sorted alphabetically (recursively)
function sortKeys(obj: Record<string, any>) {
  return Object.keys(obj)
    .sort()
    .reduce((acc: Record<string, any>, key) => {
      const value = obj[key];
      // Recursively sort nested objects
      if (value && typeof value === "object" && !Array.isArray(value)) {
        acc[key] = sortKeys(value);
      } else {
        acc[key] = value;
      }
      return acc;
    }, {});
}
