defmodule Chaudron.TransactionsTest do
  use Chaudron.DataCase
  alias Chaudron.{Transactions, Budgets}

  # Tests for transaction-related operations and their effects on budgets
  describe "transactions" do
    # Valid budget attributes for setting up test scenarios
    # Creates a needs-based budget category for groceries
    @valid_budget_attrs %{
      category: "Groceries",
      budget: 500.0,
      bucket: :needs
    }

    # Base transaction attributes representing a typical transaction
    # Uses a fixed date and amount for consistent testing
    @base_transaction_attrs %{
      date: ~U[2024-01-08 10:00:00Z],
      description: "Weekly shopping",
      amount: 150.50
    }

    # Invalid transaction attributes for testing error cases
    # Contains future date, nil description, and negative amount
    @invalid_transaction_attrs %{
      date: ~U[2025-01-08 10:00:00Z],
      description: nil,
      amount: -50.0
    }

    # Setup creates a budget for use across all tests
    # Returns the created budget in the test context
    setup do
      {:ok, budget} = Budgets.create_budget(@valid_budget_attrs)
      {:ok, budget: budget}
    end

    # Verifies successful transaction creation and budget update
    # Checks transaction details and corresponding budget spent amount
    test "create_transaction/1 with valid data creates a transaction", %{budget: budget} do
      attrs = Map.merge(@base_transaction_attrs, %{budget_id: budget.id})

      assert {:ok, %{transaction: transaction, budget_update: updated_budget}} =
               Transactions.create_transaction(attrs)

      assert transaction.description == "Weekly shopping"
      assert transaction.amount == 150.50
      assert transaction.budget_id == budget.id
      assert updated_budget.spent == 150.50
    end

    # Tests transaction creation using budget category lookup
    # Verifies both budget retrieval and transaction creation
    test "create_transaction/1 using get_budget_by_category", %{budget: _budget} do
      budget = Budgets.get_budget_by_category("Groceries")
      assert budget != nil

      create_attrs = Map.merge(@base_transaction_attrs, %{budget_id: budget.id})

      assert {:ok, %{transaction: transaction, budget_update: updated_budget}} =
               Transactions.create_transaction(create_attrs)

      assert transaction.description == @base_transaction_attrs.description
      assert transaction.amount == @base_transaction_attrs.amount
      assert transaction.budget_id == budget.id

      assert updated_budget.spent == @base_transaction_attrs.amount
    end

    # Ensures invalid transaction data results in error
    # Tests validation of date, amount, and budget association
    test "create_transaction/1 with invalid data returns error changeset" do
      attrs = Map.merge(@invalid_transaction_attrs, %{budget_id: 0})

      assert {:error, :transaction, %Ecto.Changeset{}, _changes} =
               Transactions.create_transaction(attrs)
    end

    # Tests transaction amount updates and budget recalculation
    # Verifies both transaction and budget values are updated correctly
    test "update_transaction/2 with valid data updates the transaction", %{budget: budget} do
      create_attrs = Map.merge(@base_transaction_attrs, %{budget_id: budget.id})
      {:ok, %{transaction: transaction}} = Transactions.create_transaction(create_attrs)

      update_attrs = %{amount: 200.0}

      assert {:ok, %{transaction: updated_transaction, budget_update: updated_budget}} =
               Transactions.update_transaction(transaction, update_attrs)

      assert updated_transaction.amount == 200.0
      assert updated_budget.spent == 200.0
    end

    # Verifies transaction deletion and budget spent amount reset
    # Tests complete transaction removal and budget amount recalculation
    test "delete_transaction/1 deletes the transaction and updates budget spent", %{
      budget: budget
    } do
      create_attrs = Map.merge(@base_transaction_attrs, %{budget_id: budget.id})

      {:ok, %{transaction: transaction, budget_update: initial_budget}} =
        Transactions.create_transaction(create_attrs)

      assert initial_budget.spent == @base_transaction_attrs.amount

      assert {:ok, %{transaction: deleted_transaction, budget_update: updated_budget}} =
               Transactions.delete_transaction(transaction)

      assert deleted_transaction.id == transaction.id
      assert deleted_transaction.budget_id == budget.id
      assert deleted_transaction.amount == transaction.amount

      assert updated_budget.spent == 0.0
      assert is_nil(Transactions.get_transaction(transaction.id))
    end

    # Tests transaction listing with various filters
    # Verifies budget_id and date range filtering functionality
    test "list_transactions/1 returns all transactions for a budget", %{budget: budget} do
      attrs1 = Map.merge(@base_transaction_attrs, %{budget_id: budget.id})
      attrs2 = Map.merge(@base_transaction_attrs, %{budget_id: budget.id, amount: 200.0})

      {:ok, _result1} = Transactions.create_transaction(attrs1)
      {:ok, _result2} = Transactions.create_transaction(attrs2)

      transactions = Transactions.list_transactions(%{budget_id: budget.id})
      assert length(transactions) == 2

      filtered_transactions =
        Transactions.list_transactions(%{
          budget_id: budget.id,
          start_date: ~U[2024-01-01 00:00:00Z],
          end_date: ~U[2024-01-31 23:59:59Z]
        })

      assert length(filtered_transactions) == 2

      assert Transactions.list_transactions(%{
               budget_id: budget.id,
               start_date: ~U[2025-01-01 00:00:00Z]
             }) == []
    end

    # Verifies cumulative budget spent calculations
    # Tests that multiple transactions correctly update budget spent amount
    test "multiple transactions update budget spent amount correctly", %{budget: budget} do
      attrs1 = Map.merge(@base_transaction_attrs, %{budget_id: budget.id})
      attrs2 = Map.merge(@base_transaction_attrs, %{budget_id: budget.id, amount: 200.0})

      {:ok, %{budget_update: budget1}} = Transactions.create_transaction(attrs1)
      assert budget1.spent == 150.50

      {:ok, %{budget_update: budget2}} = Transactions.create_transaction(attrs2)
      assert budget2.spent == 350.50
    end
  end
end
