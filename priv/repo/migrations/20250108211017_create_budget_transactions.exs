defmodule Chaudron.Repo.Migrations.CreateBudgetTransactions do
  use Ecto.Migration

  def change do
    create table(:budget_transactions) do
      add :date, :utc_datetime, null: false
      add :description, :string
      add :amount, :float, null: false
      add :budget_id, references(:budget_categories, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:budget_transactions, [:budget_id])
    create index(:budget_transactions, [:date])
    create index(:budget_transactions, [:date, :budget_id])
  end
end
