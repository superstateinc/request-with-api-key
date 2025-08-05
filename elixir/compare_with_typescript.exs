#!/usr/bin/env elixir

# Comparison test to verify Elixir implementation matches TypeScript behavior
# This script helps verify that the authentication headers match between implementations

Mix.install([
  {:jason, "~> 1.4"}
])

defmodule AuthComparison do
  @moduledoc """
  Helper module to test authentication header generation
  and compare with TypeScript implementation
  """
  
  def test_auth_components do
    IO.puts("🔍 Testing Authentication Component Generation")
    IO.puts("=" |> String.duplicate(50))
    
    # Test data - same as what you'd use in TypeScript
    test_data = %{
      api_key: "test-api-key",
      api_secret: "test-api-secret",
      endpoint: "v2/transactions",
      query_params: %{
        "transaction_status" => "Pending",
        "from_timestamp" => "2024-07-22T00:00:00.000Z"
      },
      body: %{
        "test_field" => "test_value",
        "nested" => %{
          "field" => "value"
        }
      }
    }
    
    test_params_hash(test_data)
    test_body_hash(test_data)
    test_key_sorting(test_data)
    
    IO.puts("\n💡 To verify exact match with TypeScript:")
    IO.puts("1. Run both implementations with the same nonce and timestamp")
    IO.puts("2. Compare the generated hashes and HMAC signatures")
    IO.puts("3. Use fixed values instead of random nonce for testing")
  end
  
  defp test_params_hash(%{endpoint: endpoint, query_params: query_params}) do
    IO.puts("\n🔗 Testing params hash generation...")
    
    # Simulate the params hash logic
    path = "/" <> String.trim_trailing(endpoint, "/")
    IO.puts("  📍 Normalized path: #{path}")
    
    unless Enum.empty?(query_params) do
      sorted_params = sort_keys_recursively(query_params)
      IO.puts("  🔄 Sorted params: #{inspect(sorted_params)}")
      
      query_string = encode_query_params(sorted_params)
      IO.puts("  🔗 Query string: #{query_string}")
      
      full_path = "#{path}?#{query_string}"
      IO.puts("  📋 Full params string: #{full_path}")
      
      params_hash = :crypto.hash(:sha256, full_path) |> Base.encode16(case: :lower)
      IO.puts("  🔐 Params hash: #{params_hash}")
    end
  end
  
  defp test_body_hash(%{body: body}) do
    IO.puts("\n📦 Testing body hash generation...")
    
    sorted_body = sort_keys_recursively(body)
    IO.puts("  🔄 Sorted body: #{inspect(sorted_body)}")
    
    body_string = Jason.encode!(sorted_body)
    IO.puts("  📝 JSON string: #{body_string}")
    
    body_hash = :crypto.hash(:sha256, body_string) |> Base.encode16(case: :lower)
    IO.puts("  🔐 Body hash: #{body_hash}")
  end
  
  defp test_key_sorting(test_data) do
    IO.puts("\n🔤 Testing key sorting logic...")
    
    # Test nested object sorting
    nested_obj = %{
      "z_field" => "last",
      "a_field" => "first", 
      "nested" => %{
        "z_nested" => "nested_last",
        "a_nested" => "nested_first"
      }
    }
    
    sorted = sort_keys_recursively(nested_obj)
    IO.puts("  📊 Original: #{inspect(nested_obj)}")
    IO.puts("  🔄 Sorted: #{inspect(sorted)}")
    
    # Verify order
    keys = Map.keys(sorted) |> Enum.to_list()
    IO.puts("  🗝️  Top-level key order: #{inspect(keys)}")
    
    if keys == Enum.sort(keys) do
      IO.puts("  ✅ Keys are properly sorted")
    else
      IO.puts("  ❌ Keys are not properly sorted")
    end
  end
  
  # Helper functions (duplicated from main module for testing)
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

# Run the comparison tests
AuthComparison.test_auth_components()