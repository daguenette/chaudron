defmodule Chaudron.Budgets.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    id: binary(),
    category: String.t(),
    budget: float(),
    spent: float(),
    bucket: atom(),
    user_id: binary()
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budget_categories" do
    field :category, :string
    field :spent, :float, default: 0.0
    field :budget, :float
    field :bucket, Ecto.Enum, values: [:bills, :needs, :wants]

    belongs_to :user, Chaudron.Accounts.User
    has_many :transactions, Chaudron.Transactions.Transaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{id: nil} = budget, attrs) do
    budget
    |> cast(attrs, [:category, :spent, :budget, :bucket, :user_id])
    |> validate_required([:category, :budget, :bucket, :user_id])
    |> validate_number(:budget, greater_than: 0)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:category, :user_id], message: "already exists for this user")
  end

  def changeset(%__MODULE__{} = budget, attrs) do
    budget
    |> cast(attrs, [:category, :spent, :budget, :bucket, :user_id])
    |> validate_number(:budget, greater_than: 0)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:category, :user_id], message: "already exists for this user")
  end
end
