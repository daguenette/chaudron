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
      |> assign(:modal_open, false)
      |> assign(:selected_bucket, nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="content-container">
      <ModalComponents.add_new_budget_modal
        modal_open={@modal_open}
        selected_bucket={@selected_bucket}
      />

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
                  <th scope="col" class="table-header">Category</th>
                  <th scope="col" class="table-header-regular">Spent</th>
                  <th scope="col" class="table-header-regular">Budget</th>
                  <th scope="col" class="table-header-regular">Progress</th>
                  <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-0">
                    <span class="sr-only">Edit</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                <%= for budget <- @budgets do %>
                  <tr>
                    <td class="table-cell">{budget.category}</td>
                    <td class="table-cell-regular">${format_amount(budget.spent)}</td>
                    <td class="table-cell-regular">${format_amount(budget.budget)}</td>
                    <td class="table-cell-regular">
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

  # Event handlers
  def handle_event("new_budget", %{"bucket" => bucket}, socket) do
    {:noreply,
     socket
     |> assign(:modal_open, true)
     |> assign(:selected_bucket, String.to_existing_atom(bucket))}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, :modal_open, false)}
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
         |> assign(:modal_open, false)
         |> assign(:bills, Map.get(budgets_by_bucket, :bills, []))
         |> assign(:needs, Map.get(budgets_by_bucket, :needs, []))
         |> assign(:wants, Map.get(budgets_by_bucket, :wants, []))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create budget category")}
    end
  end

  # Helper functions
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
