defmodule ChaudronWeb.TableComponents do
  use ChaudronWeb, :html

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :bucket, :atom, default: nil
  attr :event_name, :string, required: true

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

  attr :budgets, :list, default: []
  attr :transactions, :list, default: []
  attr :empty_phrase, :string, required: true
  attr :column_names, :list, required: true

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
              <.budget_table_body budgets={@budgets} />
            </table>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :transactions, :list, default: []
  attr :empty_phrase, :string, required: true
  attr :column_names, :list, required: true
  attr :page_number, :integer, default: 1
  attr :total_pages, :integer, default: 1

  def transaction_table(assigns) do
    ~H"""
    <div class="table-wrapper">
      <div class="table-scroll-container">
        <div class="table-inner-wrapper">
          <%= if Enum.empty?(@transactions) do %>
            <.table_empty title={@empty_phrase} />
          <% else %>
            <table class="data-table">
              <.table_header column_names={@column_names} />
              <.transactions_table_body transactions={@transactions} />
            </table>
            <div class="mt-4 flex items-center justify-between border-t border-gray-200 px-4 py-3 sm:px-6">
              <div class="flex flex-1 justify-between sm:hidden">
                <%= if @page_number > 1 do %>
                  <button
                    type="button"
                    class="relative inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                    phx-click="change_page"
                    phx-value-page={@page_number - 1}
                  >
                    Previous
                  </button>
                <% end %>
                <%= if @page_number < @total_pages do %>
                  <button
                    type="button"
                    class="relative ml-3 inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                    phx-click="change_page"
                    phx-value-page={@page_number + 1}
                  >
                    Next
                  </button>
                <% end %>
              </div>
              <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-end">
                <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
                  <%= if @page_number > 1 do %>
                    <button
                      type="button"
                      class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
                      phx-click="change_page"
                      phx-value-page={@page_number - 1}
                    >
                      <span class="sr-only">Previous</span>
                      <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                        <path
                          fill-rule="evenodd"
                          d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z"
                          clip-rule="evenodd"
                        />
                      </svg>
                    </button>
                  <% end %>

                  <%= if @total_pages <= 5 do %>
                    <%= for page <- 1..@total_pages do %>
                      <button
                        type="button"
                        class={"relative inline-flex items-center px-4 py-2 text-sm font-semibold #{if page == @page_number, do: "z-10 bg-indigo-600 text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", else: "text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"}"}
                        phx-click="change_page"
                        phx-value-page={page}
                      >
                        {page}
                      </button>
                    <% end %>
                  <% else %>
                    <%= if @page_number <= 3 do %>
                      <%= for page <- 1..3 do %>
                        <button
                          type="button"
                          class={"relative inline-flex items-center px-4 py-2 text-sm font-semibold #{if page == @page_number, do: "z-10 bg-indigo-600 text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", else: "text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"}"}
                          phx-click="change_page"
                          phx-value-page={page}
                        >
                          {page}
                        </button>
                      <% end %>
                      <span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300">...</span>
                      <%= for page <- (@total_pages - 1)..@total_pages do %>
                        <button
                          type="button"
                          class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"
                          phx-click="change_page"
                          phx-value-page={page}
                        >
                          {page}
                        </button>
                      <% end %>
                    <% else %>
                      <%= if @page_number >= @total_pages - 2 do %>
                        <button
                          type="button"
                          class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"
                          phx-click="change_page"
                          phx-value-page={1}
                        >
                          1
                        </button>
                        <button
                          type="button"
                          class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"
                          phx-click="change_page"
                          phx-value-page={2}
                        >
                          2
                        </button>
                        <span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300">...</span>
                        <%= for page <- (@total_pages - 2)..@total_pages do %>
                          <button
                            type="button"
                            class={"relative inline-flex items-center px-4 py-2 text-sm font-semibold #{if page == @page_number, do: "z-10 bg-indigo-600 text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", else: "text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"}"}
                            phx-click="change_page"
                            phx-value-page={page}
                          >
                            {page}
                          </button>
                        <% end %>
                      <% else %>
                        <button
                          type="button"
                          class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"
                          phx-click="change_page"
                          phx-value-page={1}
                        >
                          1
                        </button>
                        <span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300">...</span>
                        <%= for page <- (@page_number - 1)..(@page_number + 1) do %>
                          <button
                            type="button"
                            class={"relative inline-flex items-center px-4 py-2 text-sm font-semibold #{if page == @page_number, do: "z-10 bg-indigo-600 text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", else: "text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"}"}
                            phx-click="change_page"
                            phx-value-page={page}
                          >
                            {page}
                          </button>
                        <% end %>
                        <span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300">...</span>
                        <button
                          type="button"
                          class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"
                          phx-click="change_page"
                          phx-value-page={@total_pages}
                        >
                          {@total_pages}
                        </button>
                      <% end %>
                    <% end %>
                  <% end %>

                  <%= if @page_number < @total_pages do %>
                    <button
                      type="button"
                      class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
                      phx-click="change_page"
                      phx-value-page={@page_number + 1}
                    >
                      <span class="sr-only">Next</span>
                      <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                        <path
                          fill-rule="evenodd"
                          d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                          clip-rule="evenodd"
                        />
                      </svg>
                    </button>
                  <% end %>
                </nav>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :column_names, :list, required: true

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

  attr :budgets, :list, required: true

  def budget_table_body(assigns) do
    ~H"""
    <tbody>
      <%= for budget <- @budgets do %>
        <tr>
          <td class="column table-cell">{budget.category}</td>
          <td class="column table-cell-regular text-right font-mono">{format_amount(budget.spent)}</td>
          <td class="column table-cell-regular text-right font-mono">{format_amount(budget.budget)}</td>
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

  attr :transactions, :list, required: true

  def transactions_table_body(assigns) do
    ~H"""
    <tbody>
      <%= for transaction <- @transactions do %>
        <tr>
          <td class="column table-cell">{Calendar.strftime(transaction.inserted_at, "%Y-%m-%d")}</td>
          <td class="column table-cell-regular">{transaction.description}</td>
          <td class="column table-cell-regular text-right font-mono">{format_amount(transaction.amount)}</td>
          <td class="column table-cell-regular">
            <span class={tag_color(transaction.budget.bucket)}>
              {transaction.budget.category}
            </span>
          </td>
          <td class="table-cell-action">
            <a href="#" class="action-link" phx-click="edit_transaction" phx-value-id={transaction.id}>
              Edit<span class="sr-only">, <%= transaction.description %></span>
            </a>
          </td>
        </tr>
      <% end %>
    </tbody>
    """
  end

  attr :phx_value_bucket, :atom, default: nil
  attr :title, :string, required: true
  attr :event_name, :string, required: true

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

  attr :title, :string, required: true

  def table_empty(assigns) do
    ~H"""
    <div class="text-center py-6 text-gray-500 italic">
      {@title}
    </div>
    """
  end

  defp format_amount(amount) when is_number(amount) do
    formatted_number =
      abs(amount)
      |> :erlang.float_to_binary(decimals: 2)
      |> String.split(".")
      |> then(fn [whole, decimal] ->
        whole =
          whole
          |> String.graphemes()
          |> Enum.reverse()
          |> Enum.chunk_every(3)
          |> Enum.map(&Enum.reverse/1)
          |> Enum.reverse()
          |> Enum.join(",")
        "#{whole}.#{decimal}"
      end)

    cond do
      amount < 0 -> "($#{formatted_number})"
      true -> " $#{formatted_number} "
    end
  end
  defp format_amount(_), do: " $0.00 "

  defp calculate_progress(budget) do
    progress = budget.spent / budget.budget * 100
    min(progress, 100)
  end

  defp progress_bar_color(budget) do
    actual_progress = budget.spent / budget.budget * 100
    base_classes = "h-2.5 rounded-full"

    cond do
      actual_progress > 100 -> "#{base_classes} bg-red-500"
      actual_progress == 100 -> "#{base_classes} bg-green-500"
      true -> "#{base_classes} bg-blue-500"
    end
  end

  defp tag_color(bucket) do
    base_classes = "inline-flex items-center rounded-md px-2 py-1 text-sm font-medium ring-1 ring-inset"

    case bucket do
      :bills -> "#{base_classes} bg-orange-50 text-orange-700 ring-orange-600/20"
      :needs -> "#{base_classes} bg-blue-50 text-blue-700 ring-blue-600/20"
      :wants -> "#{base_classes} bg-purple-50 text-purple-700 ring-purple-600/20"
      _ -> "#{base_classes} bg-gray-50 text-gray-700 ring-gray-600/20"
    end
  end
end
