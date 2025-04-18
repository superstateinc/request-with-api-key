import crypto from "crypto";
import { v4 as uuidv4 } from "uuid";
import { BASE_URL, SUPERSTATE_API_KEY, SUPERSTATE_API_SECRET } from "./main";
import { QueryParams, SuperstateApiKeyRequest } from "./types";

export async function superstateApiKeyRequest({
  endpoint,
  method,
  queryParams,
  body,
}: SuperstateApiKeyRequest) {
  const headers = buildHeaders(endpoint, queryParams, body);

  // Construct URL with query parameters
  const url = new URL(`${BASE_URL}${endpoint}`);
  Object.entries(queryParams).forEach(([key, value]) => {
    url.searchParams.append(key, String(value));
  });
  console.log("Full request URL:", url.toString());

  const response = await fetch(url.toString(), {
    method,
    headers,
    ...(!["GET", "HEAD", "DELETE", "OPTIONS"].includes(method) && {
      body: JSON.stringify(body),
    }),
  });

  const data = await response.text();
  console.log(`[${response.status}] ${data}`);
  return data;
}

function buildHeaders(
  endpoint: string,
  queryParams: Record<string, any>,
  body: Record<string, any>
) {
  const nonce = uuidv4();
  const timestamp = Date.now().toString();
  const paramsHash = getParamsHash(endpoint, queryParams);
  const bodyHash = getBodyHash(body);
  const message = `${SUPERSTATE_API_KEY}${nonce}${timestamp}${paramsHash}${bodyHash}`;
  const hmac = crypto
    .createHmac("sha256", SUPERSTATE_API_SECRET)
    .update(message)
    .digest("base64");

  const superstateHeaders = {
    Authorization: `Bearer ${SUPERSTATE_API_KEY}`,
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

// Keys of the query params and body must be sorted alphabetically
function sortKeys(obj: Record<string, any>) {
  return Object.keys(obj)
    .sort()
    .reduce((acc: Record<string, any>, key) => {
      acc[key] = obj[key];
      return acc;
    }, {});
}
