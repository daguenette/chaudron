defmodule Chaudron.BudgetsTest do
  use Chaudron.DataCase
  alias Chaudron.Budgets

  # Define test data we'll reuse
  describe "budgets" do
    # Valid attributes for creating a budget
    @valid_attrs %{
      category: "Groceries",
      budget: 500.0,
      bucket: :needs
    }

    # Invalid attributes to test error cases
    @invalid_attrs %{
      category: nil,
      budget: -500.0,
      bucket: :invalid
    }

    # Each test starts with "test"
    test "create_budget/1 with valid data creates a budget" do
      # Try to create a budget with valid data
      assert {:ok, budget} = Budgets.create_budget(@valid_attrs)
      # Verify the created budget has the correct data
      assert budget.category == "Groceries"
      assert budget.budget == 500.0
      assert budget.bucket == :needs
    end

    test "create_budget/1 with invalid data returns error changeset" do
      # Try to create a budget with invalid data
      assert {:error, %Ecto.Changeset{}} = Budgets.create_budget(@invalid_attrs)
    end

    test "get_budget_by_category/1 returns budget with matching category" do
      # First create a budget
      {:ok, budget} = Budgets.create_budget(@valid_attrs)
      # Then try to fetch it by category
      assert Budgets.get_budget_by_category("Groceries") == budget
      # Also test the not-found case
      assert Budgets.get_budget_by_category("NonExistent") == nil
    end

    test "list_budgets/1 returns all budgets" do
      # Create a budget
      {:ok, budget} = Budgets.create_budget(@valid_attrs)
      # Verify it appears in the list
      assert Budgets.list_budgets() == [budget]
    end

    test "list_budgets/1 with bucket filter returns only matching budgets" do
      # Create budgets in different buckets
      {:ok, needs_budget} = Budgets.create_budget(@valid_attrs)

      {:ok, bills_budget} =
        Budgets.create_budget(%{
          category: "Rent",
          budget: 1000.0,
          bucket: :bills
        })

      # Test filtering
      assert Budgets.list_budgets(bucket: :needs) == [needs_budget]
      assert Budgets.list_budgets(bucket: :bills) == [bills_budget]
    end
  end
end
