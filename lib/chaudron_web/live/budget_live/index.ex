defmodule ChaudronWeb.BudgetLive.Index do
  use ChaudronWeb, :live_view
  alias Chaudron.Budgets
  alias ChaudronWeb.FormComponents
  alias ChaudronWeb.TableComponents

  def mount(_params, _session, socket) do
    budgets_by_bucket =
      Budgets.list_budgets()
      |> Enum.group_by(& &1.bucket)

    socket =
      socket
      |> assign(:bills, Map.get(budgets_by_bucket, :bills, []))
      |> assign(:needs, Map.get(budgets_by_bucket, :needs, []))
      |> assign(:wants, Map.get(budgets_by_bucket, :wants, []))
      |> assign(:form_errors, nil)
      |> assign(:new_budget_form, false)
      |> assign(:edit_budget_form, false)
      |> assign(:selected_bucket, nil)
      |> assign(:selected_budget, nil)
      |> assign(:show_delete_confirmation, false)
      |> assign(:column_names, ["Category", "Spent", "Budget", "Remaining"])
      |> assign(:page_title, "Budgets")
      |> assign(:current_path, "/budgets")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <!-- Modals -->
    <div class="content-container">
      <FormComponents.new_budget_form
        new_budget_form={@new_budget_form}
        selected_bucket={@selected_bucket}
        form_errors={@form_errors}
      />

      <FormComponents.edit_budget_form
        edit_budget_form={@edit_budget_form}
        budget={@selected_budget}
        form_errors={@form_errors}
      />

      <FormComponents.delete_confirmation_form show_delete_confirmation={@show_delete_confirmation} />

    <!-- Bill Content Header & Table -->
      <div class="section-spacing">
        <section class="section-container">
          <TableComponents.table_content_header
            title="Bills"
            description="Essential monthly bills like rent, utilities, and loan payments."
            bucket={:bills}
            event_name="new_budget"
          />
          <TableComponents.budget_table
            budgets={@bills}
            empty_phrase="No budget categories found."
            column_names={@column_names}
          />
        </section>

    <!-- Needs Content Header & Table -->
        <section class="section-container">
          <TableComponents.table_content_header
            title="Needs"
            description="Basic necessities like groceries, transportation, and healthcare."
            bucket={:needs}
            event_name="new_budget"
          />
          <TableComponents.budget_table
            budgets={@needs}
            empty_phrase="No budget categories found."
            column_names={@column_names}
          />
        </section>

    <!-- Wants Content Header & Table -->
        <section class="section-container">
          <TableComponents.table_content_header
            title="Wants"
            description="Non-essential spending like entertainment, dining out, and hobbies."
            bucket={:wants}
            event_name="new_budget"
          />
          <TableComponents.budget_table
            budgets={@wants}
            empty_phrase="No budget categories found."
            column_names={@column_names}
          />
        </section>
      </div>
    </div>
    """
  end

  # --- Event Handlers --- #

  @doc """
  Handles various LiveView events.

  ## Events

  ### Modal Events
    * `"close_modal"` - Closes any open modal and resets related assigns
    * `"show_delete_confirmation"` - Displays the delete confirmation modal
    * `"cancel_delete"` - Cancels the delete confirmation modal

  ### Budget Events
    * `"new_budget"` - Opens new budget form modal
      * Required attrs: `%{"bucket" => "bills" | "needs" | "wants"}`

    * `"save_budget"` - Creates a new budget category
      * Required attrs: `%{"category" => string, "budget" => string, "bucket" => "bills" | "needs" | "wants"}`

    * `"edit_budget"` - Opens edit form for a budget category
      * Required attrs: `%{"id" => string}`

    * `"update_budget"` - Updates an existing budget category
      * Optional attrs: `%{"category" => string, "budget" => string}`

    * `"delete_budget"` - Initiates budget deletion process

    * `"confirm_delete"` - Confirms and executes budget deletion

  """
  # - Modal Events -
  def handle_event("close_modal", _, socket) do
    {:noreply,
     socket
     |> assign(:new_budget_form, false)
     |> assign(:edit_budget_form, false)
     |> assign(:selected_bucket, nil)
     |> assign(:selected_budget, nil)
     |> assign(:form_errors, nil)
     |> assign(:show_delete_confirmation, false)}
  end

  def handle_event("show_delete_confirmation", _params, socket) do
    {:noreply, socket
    |> assign(:show_delete_confirmation, true)
    |> assign(:edit_budget_form, false)}
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_delete_confirmation, false)
     |> assign(:edit_budget_form, true)}
  end

  # - Budget Events -

  def handle_event("new_budget", %{"bucket" => bucket}, socket) do
    {:noreply,
     socket
     |> assign(:new_budget_form, true)
     |> assign(:selected_bucket, String.to_existing_atom(bucket))}
  end

  def handle_event(
        "save_budget",
        %{"category" => category, "budget" => budget, "bucket" => bucket},
        socket
      ) do
    budget_amount =
      case Float.parse(budget) do
        {float_value, _remainder} -> float_value
        :error -> String.to_integer(budget) * 1.0
      end

    case Budgets.create_budget(%{
           category: category,
           budget: budget_amount,
           bucket: String.to_existing_atom(bucket),
           spent: 0.0
         }) do
      {:ok, _budget} ->
        budgets_by_bucket =
          Budgets.list_budgets()
          |> Enum.group_by(& &1.bucket)

        {:noreply,
         socket
         |> assign(:new_budget_form, false)
         |> assign(:bills, Map.get(budgets_by_bucket, :bills, []))
         |> assign(:needs, Map.get(budgets_by_bucket, :needs, []))
         |> assign(:wants, Map.get(budgets_by_bucket, :wants, []))}

      {:error, changeset} ->
        error_messages = extract_error_messages(changeset)

        {:noreply,
         socket
         |> assign(:form_errors, error_messages)}
    end
  end

  def handle_event("edit_budget", %{"id" => id}, socket) do
    case Budgets.get_budget(id) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Budget not found")}

      budget ->
        {:noreply,
         socket
         |> assign(:edit_budget_form, true)
         |> assign(:selected_budget, budget)
         |> assign(:form_errors, nil)}
    end
  end

  def handle_event("update_budget", %{"value" => form_data}, socket) when is_binary(form_data) do
    params = URI.decode_query(form_data)
    handle_event("update_budget", params, socket)
  end

  def handle_event("update_budget", params, socket) do
    budget = socket.assigns.selected_budget

    attrs = %{}
    attrs = if params["category"] != "", do: Map.put(attrs, :category, params["category"]), else: attrs
    attrs = if params["budget"] != "", do: Map.put(attrs, :budget, parse_amount(params["budget"])), else: attrs
    attrs = if params["bucket"] != "", do: Map.put(attrs, :bucket, String.to_existing_atom(params["bucket"])), else: attrs

    case Budgets.update_budget(budget, attrs) do
      {:ok, _budget} ->
        {:noreply,
         socket
         |> assign(:edit_budget_form, false)
         |> assign(:selected_budget, nil)
         |> assign(:bills, Budgets.list_budgets(bucket: :bills))
         |> assign(:needs, Budgets.list_budgets(bucket: :needs))
         |> assign(:wants, Budgets.list_budgets(bucket: :wants))}

      {:error, changeset} ->
        error_messages = extract_error_messages(changeset)

        {:noreply,
         socket
         |> assign(:form_errors, error_messages)}
    end
  end

  def handle_event("delete_budget", _params, socket) do
    case Budgets.delete_budget(socket.assigns.selected_budget) do
      {:ok, _deleted_budget} ->
        budgets_by_bucket =
          Budgets.list_budgets()
          |> Enum.group_by(& &1.bucket)

        {:noreply,
         socket
         |> assign(:edit_budget_form, false)
         |> assign(:selected_budget, nil)
         |> assign(:bills, Map.get(budgets_by_bucket, :bills, []))
         |> assign(:needs, Map.get(budgets_by_bucket, :needs, []))
         |> assign(:wants, Map.get(budgets_by_bucket, :wants, []))}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "Cannot delete budget category because it has associated transactions"
         )}
    end
  end

  def handle_event("confirm_delete", _params, socket) do
    case Budgets.delete_budget(socket.assigns.selected_budget) do
      {:ok, _deleted_budget} ->
        budgets_by_bucket =
          Budgets.list_budgets()
          |> Enum.group_by(& &1.bucket)

        {:noreply,
         socket
         |> assign(:edit_budget_form, false)
         |> assign(:selected_budget, nil)
         |> assign(:show_delete_confirmation, false)
         |> assign(:bills, Map.get(budgets_by_bucket, :bills, []))
         |> assign(:needs, Map.get(budgets_by_bucket, :needs, []))
         |> assign(:wants, Map.get(budgets_by_bucket, :wants, []))}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> assign(:show_delete_confirmation, false)
         |> put_flash(
           :error,
           "Cannot delete budget category because it has associated transactions"
         )}
    end
  end

  # Private Functions

  @spec extract_error_messages(Ecto.Changeset.t()) :: String.t()
  defp extract_error_messages(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, errors} ->
      errors = List.wrap(errors) |> Enum.join(", ")
      "#{Phoenix.Naming.humanize(field)} #{errors}"
    end)
    |> Enum.join(". ")
  end

  defp parse_amount(nil), do: nil
  defp parse_amount(amount) when is_binary(amount) do
    case Float.parse(amount) do
      {float_value, _remainder} -> float_value
      :error -> String.to_integer(amount) * 1.0
    end
  end
end
