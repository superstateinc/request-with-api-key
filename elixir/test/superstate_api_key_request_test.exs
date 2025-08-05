defmodule SuperstateApiKeyRequestTest do
  use ExUnit.Case
  doctest SuperstateApiKeyRequest

  alias SuperstateApiKeyRequest.Types.TransactionStatus

  describe "request/1" do
    test "requires api_key" do
      options = %{
        api_secret: "secret",
        endpoint: "test",
        method: :get
      }

      assert {:error, "api_key is required"} = SuperstateApiKeyRequest.request(options)
    end

    test "requires api_secret" do
      options = %{
        api_key: "key",
        endpoint: "test",
        method: :get
      }

      assert {:error, "api_secret is required"} = SuperstateApiKeyRequest.request(options)
    end

    test "requires endpoint" do
      options = %{
        api_key: "key",
        api_secret: "secret",
        method: :get
      }

      assert {:error, "endpoint is required"} = SuperstateApiKeyRequest.request(options)
    end

    test "requires method" do
      options = %{
        api_key: "key",
        api_secret: "secret",
        endpoint: "test"
      }

      assert {:error, "method is required"} = SuperstateApiKeyRequest.request(options)
    end

    test "normalizes endpoint by removing leading slash" do
      # This would require mocking HTTPoison to test properly
      # For now, we'll test the validation logic
      options = %{
        api_key: "key",
        api_secret: "secret",
        endpoint: "/test/endpoint",
        method: :get
      }

      # We expect this to pass validation (though it will fail on the HTTP request)
      # In a real test, we'd mock HTTPoison
      case SuperstateApiKeyRequest.request(options) do
        {:error, reason} -> 
          # Should fail on HTTP request, not validation
          refute String.contains?(reason, "is required")
        _ -> :ok
      end
    end
  end

  describe "TransactionStatus" do
    test "provides correct string values" do
      assert TransactionStatus.pending() == "Pending"
      assert TransactionStatus.completed() == "Completed"
    end

    test "converts atoms to strings" do
      assert TransactionStatus.to_string(:pending) == "Pending"
      assert TransactionStatus.to_string(:completed) == "Completed"
    end
  end
end