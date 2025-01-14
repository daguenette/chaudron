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
    * `:user_id` - ID of the user who owns this budget

  ## Optional Attributes
    * `:spent` - Float value for amount spent (defaults to 0.0)

  ## Examples

      # Create a new budget category
      iex> create_budget(%{
      ...>   category: "Groceries",
      ...>   budget: 500.0,
      ...>   bucket: :needs,
      ...>   user_id: "user_id"
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
  Gets a budget category by its name and user_id.
  Returns nil if no budget with that category exists for the user.

  ## Examples

      iex> get_budget_by_category("Groceries", "user_id")
      %Budget{}

      iex> get_budget_by_category("NonExistent", "user_id")
      nil
  """
  @spec get_budget_by_category(String.t(), binary()) :: Budget.t() | nil
  def get_budget_by_category(category, user_id) when is_binary(category) do
    Budget
    |> where([b], b.category == ^category and b.user_id == ^user_id)
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
  Gets a budget category by ID and user_id.

  ## Examples

      iex> get_budget("43254c77-7dc6-4868-957a-ae8636c37e5c", "user_id")
      %Budget{}

      iex> get_budget("456", "user_id")
      nil
  """
  @spec get_budget(binary(), binary()) :: Budget.t() | nil
  def get_budget(id, user_id) do
    Budget
    |> where([b], b.id == ^id and b.user_id == ^user_id)
    |> Repo.one()
  end

  @doc """
  Gets a budget category by ID with preloaded transactions.

  ## Examples

      iex> get_budget_with_transactions("43254c77-7dc6-4868-957a-ae8636c37e5c", "user_id")
      %Budget{transactions: [%Transaction{}, ...]}

      iex> get_budget_with_transactions("456", "user_id")
      nil
  """
  @spec get_budget_with_transactions(binary(), binary()) :: Budget.t() | nil
  def get_budget_with_transactions(id, user_id) do
    Budget
    |> where([b], b.id == ^id and b.user_id == ^user_id)
    |> Repo.one()
    |> Repo.preload(:transactions)
  end

  @doc """
  Lists all budget categories with optional bucket type filter for a specific user.

  ## Options
    * `:bucket` - Filter budgets by bucket type (:bills, :needs, :wants)

  ## Examples

      # List all budgets for a user
      iex> list_budgets("user_id")
      [%Budget{}, ...]

      # List only 'needs' budgets for a user
      iex> list_budgets("user_id", bucket: :needs)
      [%Budget{}, ...]
  """
  @spec list_budgets(binary(), keyword()) :: [Budget.t()]
  def list_budgets(user_id, opts \\ []) do
    bucket = Keyword.get(opts, :bucket)

    Budget
    |> where([b], b.user_id == ^user_id)
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
