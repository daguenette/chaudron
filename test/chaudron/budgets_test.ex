defmodule Chaudron.BudgetsTest do
  use Chaudron.DataCase
  alias Chaudron.Budgets

  # Tests for budget-related operations in the Chaudron application
  describe "budgets" do
    # Valid attributes for creating a budget category
    # Represents a typical needs-based budget with positive amount
    @valid_attrs %{
      category: "Groceries",
      budget: 500.0,
      bucket: :needs
    }

    # Invalid attributes for testing error cases
    # Contains nil category, negative amount, and invalid bucket type
    @invalid_attrs %{
      category: nil,
      budget: -500.0,
      bucket: :invalid
    }

    # Verifies that a budget can be created with valid attributes
    # Checks category name, amount, and bucket type assignment
    test "create_budget/1 with valid data creates a budget" do
      assert {:ok, budget} = Budgets.create_budget(@valid_attrs)
      assert budget.category == "Groceries"
      assert budget.budget == 500.0
      assert budget.bucket == :needs
    end

    # Ensures that invalid attributes result in an error changeset
    # Tests data validation for required fields and constraints
    test "create_budget/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Budgets.create_budget(@invalid_attrs)
    end

    # Tests the ability to retrieve a budget by its category name
    # Verifies both successful retrieval and nil response for missing categories
    test "get_budget_by_category/1 returns budget with matching category" do
      {:ok, budget} = Budgets.create_budget(@valid_attrs)
      assert Budgets.get_budget_by_category("Groceries") == budget
      assert Budgets.get_budget_by_category("NonExistent") == nil
    end

    # Confirms that all created budgets can be listed
    # Checks that the list contains exactly the created budget
    test "list_budgets/1 returns all budgets" do
      {:ok, budget} = Budgets.create_budget(@valid_attrs)
      assert Budgets.list_budgets() == [budget]
    end

    # Tests the bucket filtering functionality of list_budgets/1
    # Creates budgets in different buckets and verifies filter results
    test "list_budgets/1 with bucket filter returns only matching budgets" do
      {:ok, needs_budget} = Budgets.create_budget(@valid_attrs)

      {:ok, bills_budget} =
        Budgets.create_budget(%{
          category: "Rent",
          budget: 1000.0,
          bucket: :bills
        })

      assert Budgets.list_budgets(bucket: :needs) == [needs_budget]
      assert Budgets.list_budgets(bucket: :bills) == [bills_budget]
    end
  end
end
