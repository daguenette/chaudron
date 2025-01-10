defmodule Chaudron.Budgets.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          category: String.t() | nil,
          spent: float() | nil,
          budget: float() | nil,
          bucket: :bills | :needs | :wants | nil,
          transactions: [Chaudron.Transactions.Transaction.t()] | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "budget_categories" do
    field :category, :string
    field :spent, :float, default: 0.0
    field :budget, :float
    field :bucket, Ecto.Enum, values: [:bills, :needs, :wants]

    has_many :transactions, Chaudron.Transactions.Transaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:category, :spent, :budget, :bucket])
    |> validate_required([:category, :spent, :budget, :bucket])
    |> validate_number(:budget, greater_than: 0)
    |> validate_number(:spent, greater_than_or_equal_to: 0)
    |> validate_inclusion(:bucket, [:bills, :needs, :wants])
    |> unique_constraint(:category, message: "already exists")
  end
end
