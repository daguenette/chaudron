defmodule Chaudron.Repo.Migrations.ModifyBudgetCategoriesUniqueConstraint do
  use Ecto.Migration

  def change do
    drop index(:budget_categories, [:category])
    create unique_index(:budget_categories, [:category, :user_id])
  end
end
