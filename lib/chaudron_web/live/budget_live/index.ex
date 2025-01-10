defmodule ChaudronWeb.BudgetLive.Index do
  use ChaudronWeb, :live_view
  alias Chaudron.Budgets
  alias ChaudronWeb.ModalComponents

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

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="content-container">
      <ModalComponents.new_budget_form
        new_budget_form={@new_budget_form}
        selected_bucket={@selected_bucket}
        form_errors={@form_errors}
      />

      <ModalComponents.edit_budget_form
        edit_budget_form={@edit_budget_form}
        budget={@selected_budget}
        form_errors={@form_errors}
      />

      <ModalComponents.delete_confirmation_form show_delete_confirmation={@show_delete_confirmation} />

      <div class="section-spacing">
        <section class="section-container">
          <.section_header
            title="Bills"
            description="Essential monthly bills like rent, utilities, and loan payments."
            bucket={:bills}
          />
          <.budget_table budgets={@bills} />
        </section>

        <section class="section-container">
          <.section_header
            title="Needs"
            description="Basic necessities like groceries, transportation, and healthcare."
            bucket={:needs}
          />
          <.budget_table budgets={@needs} />
        </section>

        <section class="section-container">
          <.section_header
            title="Wants"
            description="Non-essential spending like entertainment, dining out, and hobbies."
            bucket={:wants}
          />
          <.budget_table budgets={@wants} />
        </section>
      </div>
    </div>
    """
  end

  # Function Components

  def section_header(assigns) do
    ~H"""
    <div class="header-wrapper">
      <div class="header-content">
        <h2 class="header-title">{@title}</h2>
        <p class="header-description">
          {@description}
        </p>
      </div>
      <div class="button-wrapper">
        <button type="button" class="button-primary" phx-click="new_budget" phx-value-bucket={@bucket}>
          Add {@title} Category
        </button>
      </div>
    </div>
    """
  end

  def budget_table(assigns) do
    ~H"""
    <div class="table-wrapper">
      <div class="table-scroll-container">
        <div class="table-inner-wrapper">
          <%= if Enum.empty?(@budgets) do %>
            <div class="text-center py-6 text-gray-500 italic">
              No budget categories found
            </div>
          <% else %>
            <table class="data-table">
              <thead>
                <tr>
                  <th scope="col" class="column table-header">Category</th>
                  <th scope="col" class="column table-header-regular">Spent</th>
                  <th scope="col" class="column table-header-regular">Budget</th>
                  <th scope="col" class="column table-header-regular">Progress</th>
                  <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-0">
                    <span class="sr-only">Edit</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                <%= for budget <- @budgets do %>
                  <tr>
                    <td class="column table-cell">{budget.category}</td>
                    <td class="column table-cell-regular">${format_amount(budget.spent)}</td>
                    <td class="column table-cell-regular">${format_amount(budget.budget)}</td>
                    <td class="column table-cell-regular">
                      <div class="w-full bg-gray-200 rounded-full h-2.5">
                        <div
                          class={progress_bar_color(budget)}
                          style={"width: #{calculate_progress(budget)}%"}
                        >
                        </div>
                      </div>
                    </td>
                    <td class="table-cell-action">
                      <a href="#" class="action-link" phx-click="edit_budget" phx-value-id={budget.id}>
                        Edit<span class="sr-only">, <%= budget.category %></span>
                      </a>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # Event Handlers

  def handle_event("show_delete_confirmation", _params, socket) do
    {:noreply, assign(socket, :show_delete_confirmation, true)}
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply, assign(socket, :show_delete_confirmation, false)}
  end

  def handle_event("new_budget", %{"bucket" => bucket}, socket) do
    {:noreply,
     socket
     |> assign(:new_budget_form, true)
     |> assign(:selected_bucket, String.to_existing_atom(bucket))}
  end

  def handle_event(
        "update_budget",
        %{"category" => category, "budget" => budget},
        socket
      ) do
    current_budget = socket.assigns.selected_budget

    attrs = %{}
    attrs = if category != "", do: Map.put(attrs, :category, category), else: attrs

    attrs =
      if budget != "",
        do: Map.put(attrs, :budget, parse_budget_amount(budget)),
        else: attrs

    case Budgets.update_budget(current_budget, attrs) do
      {:ok, _updated_budget} ->
        budgets_by_bucket =
          Budgets.list_budgets()
          |> Enum.group_by(& &1.bucket)

        {:noreply,
         socket
         |> put_flash(:info, "Budget category updated successfully")
         |> assign(:edit_budget_form, false)
         |> assign(:selected_budget, nil)
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
    case Budgets.get_budget(String.to_integer(id)) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Budget category not found")}

      budget ->
        {:noreply,
         socket
         |> assign(:edit_budget_form, true)
         |> assign(:selected_budget, budget)
         |> assign(:form_errors, nil)}
    end
  end

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

  def handle_event("delete_budget", _params, socket) do
    case Budgets.delete_budget(socket.assigns.selected_budget) do
      {:ok, _deleted_budget} ->
        # Refresh the budgets list
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
         # Add this line
         |> assign(:show_delete_confirmation, false)
         |> put_flash(
           :error,
           "Cannot delete budget category because it has associated transactions"
         )}
    end
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
        # Refresh the budgets list
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

  # Private Functions

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

  defp parse_budget_amount(budget) do
    case Float.parse(budget) do
      {float_value, _remainder} -> float_value
      :error -> String.to_integer(budget) * 1.0
    end
  end

  defp format_amount(amount) do
    :erlang.float_to_binary(amount, decimals: 2)
  end

  defp calculate_progress(budget) do
    progress = budget.spent / budget.budget * 100
    min(progress, 100)
  end

  defp progress_bar_color(budget) do
    progress = calculate_progress(budget)
    base_classes = "h-2.5 rounded-full"

    cond do
      progress >= 90 -> "#{base_classes} bg-red-600"
      progress >= 75 -> "#{base_classes} bg-yellow-500"
      true -> "#{base_classes} bg-blue-600"
    end
  end
end
