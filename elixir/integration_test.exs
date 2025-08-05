#!/usr/bin/env elixir

# Integration test script for testing with real API credentials
# Run with: SUPERSTATE_API_KEY=your_key SUPERSTATE_API_SECRET=your_secret elixir integration_test.exs

Mix.install([
  {:jason, "~> 1.4"},
  {:httpoison, "~> 2.0"}
])

# Load our modules
Code.compile_file("lib/superstate_api_key_request.ex")
Code.compile_file("lib/superstate_api_key_request/types.ex")
Code.compile_file("lib/superstate_api_key_request/example.ex")

defmodule IntegrationTest do
  def run do
    IO.puts("🔌 Running Integration Tests...")
    IO.puts("=" |> String.duplicate(50))
    
    case check_credentials() do
      {:ok, api_key, api_secret} ->
        run_integration_tests(api_key, api_secret)
      {:error, reason} ->
        IO.puts("❌ #{reason}")
        IO.puts("\nTo run integration tests, set environment variables:")
        IO.puts("SUPERSTATE_API_KEY=your_key SUPERSTATE_API_SECRET=your_secret elixir integration_test.exs")
    end
  end
  
  defp check_credentials do
    api_key = System.get_env("SUPERSTATE_API_KEY")
    api_secret = System.get_env("SUPERSTATE_API_SECRET")
    
    case {api_key, api_secret} do
      {nil, _} -> {:error, "SUPERSTATE_API_KEY environment variable not set"}
      {_, nil} -> {:error, "SUPERSTATE_API_SECRET environment variable not set"}
      {key, secret} when key != "" and secret != "" -> {:ok, key, secret}
      _ -> {:error, "API credentials are empty"}
    end
  end
  
  defp run_integration_tests(api_key, api_secret) do
    IO.puts("🔑 Using API Key: #{String.slice(api_key, 0..10)}...")
    
    # Test 1: Basic GET request
    test_basic_get_request(api_key, api_secret)
    
    # Test 2: Request with query parameters
    test_request_with_query_params(api_key, api_secret)
    
    # Test 3: Test using the Example module
    test_example_module()
    
    IO.puts("\n🎉 Integration tests completed!")
  end
  
  defp test_basic_get_request(api_key, api_secret) do
    IO.puts("\n📡 Test 1: Basic GET request to /v2/transactions")
    
    case SuperstateApiKeyRequest.request(%{
      api_key: api_key,
      api_secret: api_secret,
      endpoint: "v2/transactions",
      method: :get,
      query_params: %{},
      body: %{}
    }) do
      {:ok, response} ->
        IO.puts("  ✅ Request successful!")
        IO.puts("  📊 Response type: #{inspect(get_response_type(response))}")
        if is_map(response) and Map.has_key?(response, "transactions") do
          transaction_count = length(response["transactions"])
          IO.puts("  📈 Transactions count: #{transaction_count}")
        end
        
      {:error, reason} ->
        IO.puts("  ❌ Request failed: #{reason}")
        IO.puts("  💡 This might be due to invalid credentials or network issues")
    end
  end
  
  defp test_request_with_query_params(api_key, api_secret) do
    IO.puts("\n📡 Test 2: GET request with query parameters")
    
    alias SuperstateApiKeyRequest.Types.TransactionStatus
    
    case SuperstateApiKeyRequest.request(%{
      api_key: api_key,
      api_secret: api_secret,
      endpoint: "v2/transactions",
      method: :get,
      query_params: %{
        "transaction_status" => TransactionStatus.pending()
      },
      body: %{}
    }) do
      {:ok, response} ->
        IO.puts("  ✅ Request with query params successful!")
        IO.puts("  📊 Response type: #{inspect(get_response_type(response))}")
        
      {:error, reason} ->
        IO.puts("  ❌ Request failed: #{reason}")
    end
  end
  
  defp test_example_module do
    IO.puts("\n📡 Test 3: Using Example module")
    
    case SuperstateApiKeyRequest.Example.fetch_transactions() do
      {:ok, response} ->
        IO.puts("  ✅ Example.fetch_transactions() successful!")
        IO.puts("  📊 Response type: #{inspect(get_response_type(response))}")
        
      {:error, reason} ->
        IO.puts("  ❌ Example request failed: #{reason}")
    end
    
    case SuperstateApiKeyRequest.Example.fetch_pending_transactions() do
      {:ok, response} ->
        IO.puts("  ✅ Example.fetch_pending_transactions() successful!")
        IO.puts("  📊 Response type: #{inspect(get_response_type(response))}")
        
      {:error, reason} ->
        IO.puts("  ❌ Example pending request failed: #{reason}")
    end
  end
  
  defp get_response_type(response) when is_map(response), do: :map
  defp get_response_type(response) when is_list(response), do: :list
  defp get_response_type(response), do: typeof(response)
end

# Run the integration tests
IntegrationTest.run()