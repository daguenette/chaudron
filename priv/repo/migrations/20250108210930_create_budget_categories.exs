defmodule Chaudron.Repo.Migrations.CreateBudgetCategories do
  use Ecto.Migration

  def change do
    create table(:budget_categories) do
      add :category, :string, null: false
      add :spent, :float, default: 0.0, null: false
      add :budget, :float, null: false
      add :bucket, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:budget_categories, [:category])
  end
end
