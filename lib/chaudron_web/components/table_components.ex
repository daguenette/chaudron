defmodule ChaudronWeb.TableComponents do
  use ChaudronWeb, :html

  # Table Components
  def table_content_header(assigns) do
    ~H"""
    <div class="header-wrapper">
      <div class="header-content">
        <h2 class="header-title">{@title}</h2>
        <p class="header-description">
          {@description}
        </p>
      </div>
      <.table_button phx_value_bucket={@bucket} title={@title} event_name={@event_name} />
    </div>
    """
  end

  def budget_table(assigns) do
    ~H"""
    <div class="table-wrapper">
      <div class="table-scroll-container">
        <div class="table-inner-wrapper">
          <%= if Enum.empty?(@budgets) do %>
            <.table_empty title={@empty_phrase} />
          <% else %>
            <table class="data-table">
              <.table_header column_names={@column_names} />
              <%= if @budgets do %>
                <.budget_table_body budgets={@budgets} />
              <% else %>
                <.transactions_table_body transactions={@transactions} />
              <% end %>
            </table>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # Table elements

  def table_header(assigns) do
    ~H"""
    <thead>
      <tr>
        <th scope="col" class="column table-header">{hd(@column_names)}</th>
        <%= for column <- tl(@column_names) do %>
          <th scope="col" class="column table-header-regular">{column}</th>
        <% end %>
        <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-0">
          <span class="sr-only">Edit</span>
        </th>
      </tr>
    </thead>
    """
  end

  def budget_table_body(assigns) do
    ~H"""
    <tbody>
      <%= for budget <- @budgets do %>
        <tr>
          <td class="column table-cell">{budget.category}</td>
          <td class="column table-cell-regular">${format_amount(budget.spent)}</td>
          <td class="column table-cell-regular">${format_amount(budget.budget)}</td>
          <td class="column table-cell-regular">
            <div class="w-full bg-gray-200 rounded-full h-2.5">
              <div class={progress_bar_color(budget)} style={"width: #{calculate_progress(budget)}%"}>
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
    """
  end

  def transactions_table_body(assigns) do
    ~H"""
    <tbody>
      <%= for transaction <- @transactions do %>
        <tr>
          <td class="column table-cell">{transaction.date}</td>
          <td class="column table-cell-regular">{@transaction.category}</td>
          <td class="column table-cell-regular">{transaction.description}</td>
          <td class="column table-cell-regular">${format_amount(transaction.amount)}</td>
          <td class="table-cell-action">
            <a href="#" class="action-link" phx-click="edit_transaction" phx-value-id={transaction.id}>
              Edit<span class="sr-only">, <%= transaction.date %></span>
            </a>
          </td>
        </tr>
      <% end %>
    </tbody>
    """
  end

  def table_button(assigns) do
    ~H"""
    <div class="button-wrapper">
      <button
        type="button"
        class="button-primary"
        phx-click={@event_name}
        {%{"phx-value-bucket" => @phx_value_bucket}}
      >
        Add {@title}
      </button>
    </div>
    """
  end

  def table_empty(assigns) do
    ~H"""
    <div class="text-center py-6 text-gray-500 italic">
      {@title}
    </div>
    """
  end

  # Private Table Functions
  defp format_amount(amount) do
    :erlang.float_to_binary(amount, decimals: 2)
  end

  defp calculate_progress(budget) do
    progress = budget.spent / budget.budget * 100
    min(progress, 100)
  end

  defp progress_bar_color(budget) do
    actual_progress = budget.spent / budget.budget * 100
    base_classes = "h-2.5 rounded-full"

    cond do
      actual_progress > 100 -> "#{base_classes} bg-red-600"
      actual_progress == 100 -> "#{base_classes} bg-green-500"
      actual_progress >= 75 -> "#{base_classes} bg-yellow-500"
      true -> "#{base_classes} bg-blue-600"
    end
  end
end
