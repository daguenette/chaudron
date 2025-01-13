defmodule Chaudron.Repo.Migrations.ModifyIdsToUuid do
  use Ecto.Migration

  def up do
    # Enable uuid-ossp extension
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\""

    # Drop the existing foreign key constraint
    drop constraint(:budget_transactions, "budget_transactions_budget_id_fkey")

    # Add temporary columns
    alter table(:budget_categories) do
      add :uuid_id, :uuid, default: fragment("uuid_generate_v4()")
    end

    alter table(:budget_transactions) do
      add :uuid_id, :uuid, default: fragment("uuid_generate_v4()")
      add :budget_uuid_id, :uuid
    end

    # Copy data to new UUID columns
    execute """
    UPDATE budget_transactions bt
    SET budget_uuid_id = bc.uuid_id
    FROM budget_categories bc
    WHERE bt.budget_id = bc.id
    """

    # Drop old columns and rename new ones for budget_categories
    execute "ALTER TABLE budget_categories DROP COLUMN id"
    execute "ALTER TABLE budget_categories ALTER COLUMN uuid_id SET NOT NULL"
    execute "ALTER TABLE budget_categories ALTER COLUMN uuid_id SET DEFAULT uuid_generate_v4()"
    execute "ALTER TABLE budget_categories RENAME COLUMN uuid_id TO id"

    # Drop old columns and rename new ones for budget_transactions
    execute "ALTER TABLE budget_transactions DROP COLUMN id"
    execute "ALTER TABLE budget_transactions DROP COLUMN budget_id"
    execute "ALTER TABLE budget_transactions ALTER COLUMN uuid_id SET NOT NULL"
    execute "ALTER TABLE budget_transactions ALTER COLUMN uuid_id SET DEFAULT uuid_generate_v4()"
    execute "ALTER TABLE budget_transactions RENAME COLUMN uuid_id TO id"
    execute "ALTER TABLE budget_transactions RENAME COLUMN budget_uuid_id TO budget_id"

    # Add primary key constraints
    execute "ALTER TABLE budget_categories ADD PRIMARY KEY (id)"
    execute "ALTER TABLE budget_transactions ADD PRIMARY KEY (id)"

    # Add back the foreign key constraint
    alter table(:budget_transactions) do
      modify :budget_id, :uuid, null: false
    end

    create index(:budget_transactions, [:budget_id])

    execute """
    ALTER TABLE budget_transactions
    ADD CONSTRAINT budget_transactions_budget_id_fkey
    FOREIGN KEY (budget_id)
    REFERENCES budget_categories(id)
    ON DELETE CASCADE
    """
  end

  def down do
    raise "Cannot revert this migration"
  end
end
