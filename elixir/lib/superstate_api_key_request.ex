defmodule SuperstateApiKeyRequest do
  @moduledoc """
  Make an API request to a Superstate endpoint that requires an API key.

  This module provides functionality to authenticate and make HTTP requests
  to Superstate API endpoints using API key authentication with HMAC signing.
  """

  @default_base_url "https://api.superstate.com"

  @doc """
  Makes an authenticated API request to a Superstate endpoint.

  ## Parameters

    * `options` - A map containing the request configuration:
      * `:base_url` - Base URL for the API (defaults to "https://api.superstate.com")
      * `:api_key` - Your Superstate API key (required)
      * `:api_secret` - Your Superstate API secret (required)
      * `:endpoint` - The API endpoint to call (required)
      * `:method` - HTTP method (:get, :post, :put, :delete)
      * `:query_params` - Map of query parameters (optional)
      * `:body` - Request body as a map (optional)

  ## Returns

    * `{:ok, response}` - On successful request
    * `{:error, reason}` - On failure

  ## Examples

      iex> SuperstateApiKeyRequest.request(%{
      ...>   api_key: "your_api_key",
      ...>   api_secret: "your_api_secret",
      ...>   endpoint: "v2/transactions",
      ...>   method: :get,
      ...>   query_params: %{},
      ...>   body: %{}
      ...> })
      {:ok, %{...}}

  """
  @spec request(map()) :: {:ok, map()} | {:error, term()}
  def request(options) do
    with {:ok, validated_options} <- validate_options(options),
         {:ok, headers} <- build_headers(validated_options),
         {:ok, url} <- build_url(validated_options),
         {:ok, response} <- make_request(validated_options, headers, url) do
      {:ok, response}
    end
  end

  defp validate_options(options) do
    required_fields = [:api_key, :api_secret, :endpoint, :method]
    
    case Enum.find(required_fields, &(not Map.has_key?(options, &1))) do
      nil ->
        validated = options
        |> Map.put_new(:base_url, @default_base_url)
        |> Map.put_new(:query_params, %{})
        |> Map.put_new(:body, %{})
        |> Map.update(:endpoint, "", &normalize_endpoint/1)
        
        {:ok, validated}
      missing_field ->
        {:error, "#{missing_field} is required"}
    end
  end

  defp normalize_endpoint(endpoint) when is_binary(endpoint) do
    String.trim_leading(endpoint, "/")
  end

  defp build_headers(%{api_key: api_key, api_secret: api_secret, endpoint: endpoint, query_params: query_params, body: body}) do
    nonce = generate_nonce()
    timestamp = generate_timestamp()
    params_hash = get_params_hash(endpoint, query_params)
    body_hash = get_body_hash(body)
    
    message = "#{api_key}#{nonce}#{timestamp}#{params_hash}#{body_hash}"
    hmac = :crypto.mac(:hmac, :sha256, api_secret, message) |> Base.encode64()

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"X-Nonce", nonce},
      {"X-Timestamp", timestamp},
      {"X-Params-Hash", params_hash},
      {"X-Body-Hash", body_hash},
      {"X-Hmac", hmac},
      {"Content-Type", "application/json"}
    ]

    {:ok, headers}
  end

  defp build_url(%{base_url: base_url, endpoint: endpoint, query_params: query_params}) do
    url = "#{base_url}/#{endpoint}"
    
    case Enum.empty?(query_params) do
      true -> {:ok, url}
      false ->
        query_string = URI.encode_query(query_params)
        {:ok, "#{url}?#{query_string}"}
    end
  end

  defp make_request(%{method: method, body: body}, headers, url) do
    request_body = if method in [:get, :head, :delete, :options] do
      ""
    else
      Jason.encode!(body)
    end

    case HTTPoison.request(method, url, request_body, headers) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} when status_code in 200..299 ->
        case Jason.decode(response_body) do
          {:ok, decoded} -> {:ok, decoded}
          {:error, _} -> {:error, "Invalid JSON response"}
        end
      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        {:error, "Request failed with status #{status_code}: #{response_body}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  defp generate_nonce do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  defp generate_timestamp do
    System.system_time(:millisecond) |> Integer.to_string()
  end

  defp get_params_hash(endpoint, query_params) do
    # Ensure leading slash, remove trailing slash
    path = "/" <> String.trim_trailing(endpoint, "/")
    
    params_string = case Enum.empty?(query_params) do
      true -> path
      false ->
        sorted_params = sort_keys_recursively(query_params)
        query_string = encode_query_params(sorted_params)
        "#{path}?#{query_string}"
    end

    :crypto.hash(:sha256, params_string) |> Base.encode16(case: :lower)
  end

  defp get_body_hash(body) do
    sorted_body = sort_keys_recursively(body)
    body_string = Jason.encode!(sorted_body)
    :crypto.hash(:sha256, body_string) |> Base.encode16(case: :lower)
  end

  defp sort_keys_recursively(map) when is_map(map) do
    map
    |> Enum.sort_by(fn {key, _} -> key end)
    |> Enum.into(%{}, fn {key, value} ->
      {key, sort_keys_recursively(value)}
    end)
  end

  defp sort_keys_recursively(value), do: value

  defp encode_query_params(params) do
    params
    |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
    |> Enum.join("&")
  end
end