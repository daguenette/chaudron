defmodule Chaudron.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          date: DateTime.t() | nil,
          description: String.t() | nil,
          amount: float() | nil,
          budget_id: integer() | nil,
          budget: Chaudron.Budgets.Budget.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "budget_transactions" do
    field :date, :utc_datetime
    field :description, :string
    field :amount, :float

    belongs_to :budget, Chaudron.Budgets.Budget, foreign_key: :budget_id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:date, :description, :amount])
    |> validate_required([:date, :description, :amount])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:budget_id)
    |> validate_date_not_in_future()
  end

  defp validate_date_not_in_future(changeset) do
    validate_change(changeset, :date, fn :date, date ->
      if DateTime.compare(date, DateTime.utc_now()) == :gt do
        [date: "cannot be in the future"]
      else
        []
      end
    end)
  end
end
