defmodule Chaudron.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budget_transactions" do
    field :description, :string
    field :amount, :float
    field :date, :utc_datetime

    belongs_to :budget, Chaudron.Budgets.Budget
    belongs_to :user, Chaudron.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{id: nil} = transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :amount, :budget_id, :date, :user_id])
    |> validate_required([:description, :amount, :budget_id, :date, :user_id])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:budget_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset(%__MODULE__{} = transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :amount, :budget_id, :date, :user_id])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:budget_id)
    |> foreign_key_constraint(:user_id)
  end
end
