defmodule Chaudron.Repo.Migrations.ModifyBudgetTransactionsForeignKey do
  use Ecto.Migration

  def change do
    drop constraint(:budget_transactions, "budget_transactions_budget_id_fkey")

    alter table(:budget_transactions) do
      modify :budget_id, references(:budget_categories, on_delete: :delete_all), null: false
    end
  end
end
