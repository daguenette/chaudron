defmodule Chaudron.Transactions do
  import Ecto.Query
  alias Chaudron.Repo
  alias Chaudron.Transactions.Transaction
  alias Chaudron.Budgets
  alias Chaudron.Budgets.Budget

  @doc """
  Creates a new transaction and updates the associated budget's spent amount.

  ## Required Attributes
    * `:date` - DateTime of the transaction
    * `:description` - String description of the transaction
    * `:amount` - Float value of the transaction amount
    * `:budget_id` - ID of the associated budget category
    * `:user_id` - ID of the user who owns this transaction

  ## Examples

      # Create a new transaction
      iex> create_transaction(%{
      ...>   date: ~U[2024-01-08 10:00:00Z],
      ...>   description: "Weekly groceries",
      ...>   amount: 150.50,
      ...>   budget_id: "budget_id",
      ...>   user_id: "user_id"
      ...> })
      {:ok, %{transaction: %Transaction{}, budget_update: %Budget{}}}

      # Will return error with invalid attributes
      iex> create_transaction(%{
      ...>   date: ~U[2025-01-08 10:00:00Z],  # Future date
      ...>   amount: -50.0  # Negative amount
      ...> })
      {:error, :transaction, %Ecto.Changeset{}, %{}}
  """
  @spec create_transaction(map()) ::
          {:ok, %{transaction: Transaction.t(), budget_update: Budget.t()}}
          | {:error, Ecto.Multi.name(), any(), %{optional(Ecto.Multi.name()) => any()}}
  def create_transaction(attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:transaction, Transaction.changeset(%Transaction{}, attrs))
    |> Ecto.Multi.run(:budget_update, fn repo, %{transaction: transaction} ->
      budget = repo.get!(Budget, transaction.budget_id)
      Budgets.update_spent_amount(budget)
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a transaction and recalculates the budget's spent amount.

  ## Examples

      iex> update_transaction(transaction, %{amount: 200.0})
      {:ok, %{transaction: %Transaction{}, budget_update: %Budget{}}}
  """
  @spec update_transaction(Transaction.t(), map()) ::
          {:ok, %{transaction: Transaction.t(), budget_update: Budget.t()}}
          | {:error, Ecto.Multi.name(), any(), %{optional(Ecto.Multi.name()) => any()}}
  def update_transaction(%Transaction{} = transaction, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:transaction, Transaction.changeset(transaction, attrs))
    |> Ecto.Multi.run(:budget_update, fn repo, %{transaction: updated_transaction} ->
      budget = repo.get!(Budget, updated_transaction.budget_id)
      Budgets.update_spent_amount(budget)
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes a transaction and updates the budget's spent amount.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %{transaction: %Transaction{}, budget_update: %Budget{}}}
  """
  @spec delete_transaction(Transaction.t()) ::
          {:ok, %{transaction: Transaction.t(), budget_update: Budget.t()}}
          | {:error, Ecto.Multi.name(), any(), %{optional(Ecto.Multi.name()) => any()}}
  def delete_transaction(%Transaction{} = transaction) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:transaction, transaction)
    |> Ecto.Multi.run(:budget_update, fn repo, _changes ->
      budget = repo.get!(Budget, transaction.budget_id)
      Budgets.update_spent_amount(budget)
    end)
    |> Repo.transaction()
  end

  @doc """
  Gets a transaction by ID and user_id.

  ## Examples

      iex> get_transaction("123", "user_id")
      %Transaction{}

      iex> get_transaction("456", "user_id")
      nil
  """
  @spec get_transaction(binary(), binary()) :: Transaction.t() | nil
  def get_transaction(id, user_id) do
    Transaction
    |> where([t], t.id == ^id and t.user_id == ^user_id)
    |> Repo.one()
  end

  @doc """
  Lists transactions with optional filters and pagination.

  ## Options
    * `:budget_id` - Filter by budget category
    * `:start_date` - Filter transactions after this date
    * `:end_date` - Filter transactions before this date
    * `:page` - Page number (defaults to 1)
    * `:per_page` - Number of items per page (defaults to 10)
    * `:user_id` - Required. Filter transactions by user

  ## Examples

      # List all transactions with pagination
      iex> list_transactions(%{user_id: "user_id", page: 1})
      %{entries: [%Transaction{}, ...], page_number: 1, total_pages: 5}

      # List transactions for a specific budget and date range with pagination
      iex> list_transactions(%{
      ...>   user_id: "user_id",
      ...>   budget_id: "budget_id",
      ...>   start_date: ~U[2024-01-01 00:00:00Z],
      ...>   end_date: ~U[2024-01-31 23:59:59Z],
      ...>   page: 2
      ...> })
      %{entries: [%Transaction{}, ...], page_number: 2, total_pages: 3}
  """
  @spec list_transactions(map()) :: %{
          entries: [Transaction.t()],
          page_number: integer(),
          total_pages: integer()
        }
  def list_transactions(opts \\ %{}) do
    page = Map.get(opts, :page, 1)
    per_page = Map.get(opts, :per_page, 10)
    user_id = Map.get(opts, :user_id)

    query =
      Transaction
      |> where([t], t.user_id == ^user_id)
      |> maybe_filter_by_budget(opts[:budget_id])
      |> maybe_filter_by_date_range(opts[:start_date], opts[:end_date])
      |> order_by([t], desc: t.date)
      |> preload(:budget)

    total_entries = Repo.aggregate(query, :count, :id)
    total_pages = ceil(total_entries / per_page)

    entries =
      query
      |> limit(^per_page)
      |> offset(^((page - 1) * per_page))
      |> Repo.all()

    %{
      entries: entries,
      page_number: page,
      total_pages: total_pages
    }
  end

  # Private functions

  defp maybe_filter_by_budget(query, nil), do: query

  defp maybe_filter_by_budget(query, budget_id) when is_binary(budget_id) do
    where(query, [t], t.budget_id == ^budget_id)
  end

  defp maybe_filter_by_date_range(query, nil, nil), do: query

  defp maybe_filter_by_date_range(query, start_date, nil) do
    where(query, [t], t.date >= ^start_date)
  end

  defp maybe_filter_by_date_range(query, nil, end_date) do
    where(query, [t], t.date <= ^end_date)
  end

  defp maybe_filter_by_date_range(query, start_date, end_date) do
    where(query, [t], t.date >= ^start_date and t.date <= ^end_date)
  end
end
