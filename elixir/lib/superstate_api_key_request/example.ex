defmodule SuperstateApiKeyRequest.Example do
  @moduledoc """
  Example usage of the SuperstateApiKeyRequest module.
  
  This module demonstrates how to use the SuperstateApiKeyRequest to fetch
  transactions from the Superstate API.
  """

  alias SuperstateApiKeyRequest.Types.TransactionStatus

  @transactions_endpoint "v2/transactions"

  @doc """
  Example function that fetches transactions from the Superstate API.
  
  Make sure to set the following environment variables:
  - SUPERSTATE_API_KEY
  - SUPERSTATE_API_SECRET
  
  ## Examples
  
      iex> SuperstateApiKeyRequest.Example.fetch_transactions()
      {:ok, %{...}}
      
  """
  def fetch_transactions(query_params \\ %{}) do
    api_key = System.get_env("SUPERSTATE_API_KEY")
    api_secret = System.get_env("SUPERSTATE_API_SECRET")

    case {api_key, api_secret} do
      {nil, _} -> {:error, "SUPERSTATE_API_KEY environment variable must be set"}
      {_, nil} -> {:error, "SUPERSTATE_API_SECRET environment variable must be set"}
      {key, secret} ->
        SuperstateApiKeyRequest.request(%{
          api_key: key,
          api_secret: secret,
          endpoint: @transactions_endpoint,
          method: :get,
          query_params: query_params,
          body: %{}
        })
    end
  end

  @doc """
  Example with filtered query parameters.
  
  ## Examples
  
      iex> SuperstateApiKeyRequest.Example.fetch_pending_transactions()
      {:ok, %{...}}
      
  """
  def fetch_pending_transactions do
    query_params = %{
      "transaction_status" => TransactionStatus.pending()
    }
    
    fetch_transactions(query_params)
  end

  @doc """
  Example with date range filtering.
  
  ## Examples
  
      iex> SuperstateApiKeyRequest.Example.fetch_transactions_by_date_range(
      ...>   "2024-07-22T00:00:00.000Z",
      ...>   "2024-07-23T00:00:00.000Z"
      ...> )
      {:ok, %{...}}
      
  """
  def fetch_transactions_by_date_range(from_timestamp, until_timestamp) do
    query_params = %{
      "from_timestamp" => from_timestamp,
      "until_timestamp" => until_timestamp
    }
    
    fetch_transactions(query_params)
  end

  @doc """
  Run the example - fetches all transactions and prints them.
  """
  def run do
    case fetch_transactions() do
      {:ok, transactions} ->
        IO.puts("Transactions fetched successfully:")
        IO.inspect(transactions, pretty: true)
        
      {:error, reason} ->
        IO.puts("Error fetching transactions: #{reason}")
    end
  end
end