defmodule Chaudron.Repo.Migrations.AddUserIdToBudgetsAndTransactions do
  use Ecto.Migration

  def change do
    alter table(:budget_categories) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
    end

    alter table(:budget_transactions) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
    end

    create index(:budget_categories, [:user_id])
    create index(:budget_transactions, [:user_id])
  end
end
