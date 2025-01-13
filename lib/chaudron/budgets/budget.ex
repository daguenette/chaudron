defmodule Chaudron.Budgets.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budget_categories" do
    field :category, :string
    field :spent, :float, default: 0.0
    field :budget, :float
    field :bucket, Ecto.Enum, values: [:bills, :needs, :wants]

    has_many :transactions, Chaudron.Transactions.Transaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{id: nil} = budget, attrs) do
    budget
    |> cast(attrs, [:category, :spent, :budget, :bucket])
    |> validate_required([:category, :budget, :bucket])
    |> validate_number(:budget, greater_than: 0)
  end

  def changeset(%__MODULE__{} = budget, attrs) do
    budget
    |> cast(attrs, [:category, :spent, :budget, :bucket])
    |> validate_number(:budget, greater_than: 0)
  end
end
