defmodule SuperstateApiKeyRequest.Types do
  @moduledoc """
  Type definitions and structs for Superstate API Key Request.
  """

  @type request_method :: :get | :post | :put | :delete
  @type query_params :: %{String.t() => String.t() | number() | boolean() | nil}

  @doc """
  Transaction status enum values.
  """
  @type transaction_status :: :pending | :completed

  @doc """
  Configuration for making a Superstate API request.
  """
  @type request_config :: %{
    base_url: String.t(),
    api_key: String.t(),
    api_secret: String.t(),
    endpoint: String.t(),
    method: request_method(),
    query_params: query_params(),
    body: map()
  }

  @doc """
  Query parameters for the GetTransactionsV2 endpoint.
  """
  @type get_transactions_v2_query :: %{
    transaction_status: transaction_status() | nil,
    from_timestamp: String.t() | nil,
    until_timestamp: String.t() | nil,
    transaction_hash: String.t() | nil
  }

  defmodule TransactionStatus do
    @moduledoc """
    Constants for transaction status values.
    """
    
    @pending "Pending"
    @completed "Completed"

    def pending, do: @pending
    def completed, do: @completed

    @doc """
    Converts atom to string representation.
    """
    def to_string(:pending), do: @pending
    def to_string(:completed), do: @completed
  end
end