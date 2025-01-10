defmodule Chaudron.Budgets do
  import Ecto.Query
  alias Chaudron.Transactions.Transaction
  alias Chaudron.Repo
  alias Chaudron.Budgets.Budget

  @doc """
  Creates a new budget category.

  ## Required Attributes
    * `:category` - String name of the budget category
    * `:budget` - Float value for the allocated budget amount
    * `:bucket` - Atom of either `:bills`, `:needs`, or `:wants`

  ## Optional Attributes
    * `:spent` - Float value for amount spent (defaults to 0.0)

  ## Examples

      # Create a new budget category
      iex> create_budget(%{
      ...>   category: "Groceries",
      ...>   budget: 500.0,
      ...>   bucket: :needs
      ...> })
      {:ok, %Budget{}}

      # Will return error with invalid attributes
      iex> create_budget(%{
      ...>   category: "Groceries",
      ...>   budget: -500.0,
      ...>   bucket: :invalid
      ...> })
      {:error, %Ecto.Changeset{}}
  """
  @spec create_budget(map()) :: {:ok, Budget.t()} | {:error, Ecto.Changeset.t()}
  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing budget category.

  ## Required Attributes
    * `:category` - String name of the budget category
    * `:budget` - Float value for the allocated budget amount
    * `:bucket` - Atom of either `:bills`, `:needs`, or `:wants`

  ## Optional Attributes
    * `:spent` - Float value for amount spent

  ## Examples

      # Update a budget category
      iex> update_budget(budget, %{budget: 600.0})
      {:ok, %Budget{}}

      # Will return error with invalid attributes
      iex> update_budget(budget, %{budget: -500.0})
      {:error, %Ecto.Changeset{}}
  """
  @spec update_budget(Budget.t(), map()) :: {:ok, Budget.t()} | {:error, Ecto.Changeset.t()}
  def update_budget(%Budget{} = budget, attrs) do
    budget
    |> Budget.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets a budget category by its name.
  Returns nil if no budget with that category exists.

  ## Examples

      iex> get_budget_by_category("Groceries")
      %Budget{}

      iex> get_budget_by_category("NonExistent")
      nil
  """
  @spec get_budget_by_category(String.t()) :: Budget.t() | nil
  def get_budget_by_category(category) when is_binary(category) do
    Budget
    |> where([b], b.category == ^category)
    |> Repo.one()
  end

  @doc """
  Deletes a budget category.
  Will fail if there are associated transactions.

  ## Examples

      iex> delete_budget(budget)
      {:ok, %Budget{}}

      # With existing transactions
      iex> delete_budget(budget_with_transactions)
      {:error, %Ecto.Changeset{}}
  """
  @spec delete_budget(Budget.t()) :: {:ok, Budget.t()} | {:error, Ecto.Changeset.t()}
  def delete_budget(%Budget{} = budget) do
    Repo.delete(budget)
  end

  @doc """
  Gets a budget category by ID.

  ## Examples

      iex> get_budget(123)
      %Budget{}

      iex> get_budget(456)
      nil
  """
  @spec get_budget(integer()) :: Budget.t() | nil
  def get_budget(id) do
    Repo.get(Budget, id)
  end

  @doc """
  Gets a budget category by ID with preloaded transactions.

  ## Examples

      iex> get_budget_with_transactions(123)
      %Budget{transactions: [%Transaction{}, ...]}

      iex> get_budget_with_transactions(456)
      nil
  """
  @spec get_budget_with_transactions(integer()) :: Budget.t() | nil
  def get_budget_with_transactions(id) do
    Budget
    |> Repo.get(id)
    |> Repo.preload(:transactions)
  end

  @doc """
  Lists all budget categories with optional bucket type filter.

  ## Options
    * `:bucket` - Filter budgets by bucket type (:bills, :needs, :wants)

  ## Examples

      # List all budgets
      iex> list_budgets()
      [%Budget{}, ...]

      # List only 'needs' budgets
      iex> list_budgets(bucket: :needs)
      [%Budget{}, ...]
  """
  @spec list_budgets(keyword()) :: [Budget.t()]
  def list_budgets(opts \\ []) do
    bucket = Keyword.get(opts, :bucket)

    Budget
    |> maybe_filter_by_bucket(bucket)
    |> order_by([b], desc: b.budget)
    |> Repo.all()
  end

  @doc """
  Calculates remaining budget for a category.

  ## Examples

      iex> get_remaining_budget(budget)
      150.50
  """
  @spec get_remaining_budget(Budget.t()) :: float()
  def get_remaining_budget(%Budget{} = budget) do
    budget.budget - budget.spent
  end

  @doc """
  Updates the spent amount for a budget category.
  This is typically called after transaction changes.

  ## Examples

      iex> update_spent_amount(budget)
      {:ok, %Budget{}}
  """
  @spec update_spent_amount(Budget.t()) :: {:ok, Budget.t()} | {:error, Ecto.Changeset.t()}
  def update_spent_amount(%Budget{} = budget) do
    total_spent =
      Transaction
      |> where([t], t.budget_id == ^budget.id)
      |> select([t], sum(t.amount))
      |> Repo.one() || 0.0

    update_budget(budget, %{spent: total_spent})
  end

  # Private functions

  defp maybe_filter_by_bucket(query, nil), do: query

  defp maybe_filter_by_bucket(query, bucket) do
    where(query, [b], b.bucket == ^bucket)
  end
end
