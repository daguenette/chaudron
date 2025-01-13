defmodule ChaudronWeb.TransactionLive.Index do
  use ChaudronWeb, :live_view
  alias Chaudron.Transactions
  alias Chaudron.Budgets
  alias ChaudronWeb.TableComponents
  alias ChaudronWeb.FormComponents

  def mount(_params, _session, socket) do
    transactions_page = Transactions.list_transactions()

    {:ok,
     socket
     |> assign(:page_title, "Transactions")
     |> assign(:transactions, transactions_page.entries)
     |> assign(:page_number, transactions_page.page_number)
     |> assign(:total_pages, transactions_page.total_pages)
     |> assign(:column_names, ["Date", "Description", "Amount", "Category"])
     |> assign(:empty_phrase, "No transactions found")
     |> assign(:budgets, Budgets.list_budgets())
     |> assign(:new_transaction_form, false)
     |> assign(:edit_transaction_form, false)
     |> assign(:selected_transaction, nil)
     |> assign(:form_errors, nil)
     |> assign(:show_delete_confirmation, false)}
  end

  def render(assigns) do
    ~H"""
    <!-- Modals -->
    <div class="content-container">
      <FormComponents.new_transaction_form
        new_transaction_form={@new_transaction_form}
        budgets={@budgets}
        form_errors={@form_errors}
      />

      <FormComponents.edit_transaction_form
        edit_transaction_form={@edit_transaction_form}
        transaction={@selected_transaction}
        budgets={@budgets}
        form_errors={@form_errors}
      />

      <FormComponents.delete_confirmation_form show_delete_confirmation={@show_delete_confirmation} />

      <!-- Transaction Content Header & Table -->
      <div class="section-spacing">
        <section class="section-container">
          <TableComponents.table_content_header
            title="Transactions"
            description="All your transactions across budget categories."
            event_name="new_transaction"
          />
          <TableComponents.transaction_table
            transactions={@transactions}
            empty_phrase={@empty_phrase}
            column_names={@column_names}
            page_number={@page_number}
            total_pages={@total_pages}
          />
        </section>
      </div>
    </div>
    """
  end

  # Form Events
  def handle_event("new_transaction", _params, socket) do
    {:noreply,
     socket
     |> assign(:new_transaction_form, true)
     |> assign(:form_errors, nil)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:new_transaction_form, false)
     |> assign(:edit_transaction_form, false)
     |> assign(:show_delete_confirmation, false)
     |> assign(:selected_transaction, nil)
     |> assign(:form_errors, nil)}
  end

  # Save Transaction Events
  def handle_event("save_transaction", %{"value" => form_data}, socket) do
    params = URI.decode_query(form_data)
    create_transaction_from_params(params, socket)
  end

  def handle_event("save_transaction", %{"description" => _, "budget_id" => _, "amount" => _} = params, socket) do
    create_transaction_from_params(params, socket)
  end

  # Edit Transaction Events
  def handle_event("edit_transaction", %{"id" => id}, socket) do
    case Transactions.get_transaction(id) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Transaction not found")}

      transaction ->
        {:noreply,
         socket
         |> assign(:edit_transaction_form, true)
         |> assign(:selected_transaction, transaction)
         |> assign(:form_errors, nil)}
    end
  end

  def handle_event("update_transaction", params, socket) do
    transaction = socket.assigns.selected_transaction

    attrs = %{}
    attrs = if params["description"] != "", do: Map.put(attrs, :description, params["description"]), else: attrs
    attrs = if params["amount"] != "", do: Map.put(attrs, :amount, parse_amount(params["amount"])), else: attrs
    attrs = if params["budget_id"] != "", do: Map.put(attrs, :budget_id, params["budget_id"]), else: attrs

    case Transactions.update_transaction(transaction, attrs) do
      {:ok, %{transaction: _transaction}} ->
        transactions_page = Transactions.list_transactions(%{page: socket.assigns.page_number})

        {:noreply,
         socket
         |> assign(:edit_transaction_form, false)
         |> assign(:selected_transaction, nil)
         |> assign(:transactions, transactions_page.entries)
         |> assign(:page_number, transactions_page.page_number)
         |> assign(:total_pages, transactions_page.total_pages)
         |> assign(:budgets, Budgets.list_budgets())}

      {:error, :transaction, changeset, _changes} ->
        error_messages = extract_error_messages(changeset)

        {:noreply,
         socket
         |> assign(:form_errors, error_messages)}
    end
  end

  # Delete Events
  def handle_event("show_delete_confirmation", _params, socket) do
    {:noreply,
     socket
     |> assign(:edit_transaction_form, false)
     |> assign(:show_delete_confirmation, true)}
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply,
     socket
     |> assign(:edit_transaction_form, true)
     |> assign(:show_delete_confirmation, false)}
  end

  def handle_event("confirm_delete", _params, socket) do
    transaction = socket.assigns.selected_transaction

    case Transactions.delete_transaction(transaction) do
      {:ok, _result} ->
        transactions_page = Transactions.list_transactions(%{page: socket.assigns.page_number})

        {:noreply,
         socket
         |> assign(:edit_transaction_form, false)
         |> assign(:selected_transaction, nil)
         |> assign(:show_delete_confirmation, false)
         |> assign(:transactions, transactions_page.entries)
         |> assign(:page_number, transactions_page.page_number)
         |> assign(:total_pages, transactions_page.total_pages)
         |> assign(:budgets, Budgets.list_budgets())}

      {:error, :transaction, _changeset, _changes} ->
        {:noreply,
         socket
         |> assign(:show_delete_confirmation, false)
         |> put_flash(:error, "Failed to delete transaction")}
    end
  end

  # Pagination Events
  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    transactions_page = Transactions.list_transactions(%{page: page})

    {:noreply,
     socket
     |> assign(:transactions, transactions_page.entries)
     |> assign(:page_number, transactions_page.page_number)
     |> assign(:total_pages, transactions_page.total_pages)}
  end

  # Private Functions
  defp create_transaction_from_params(params, socket) do
    attrs = %{
      date: DateTime.utc_now(),
      description: params["description"],
      amount: parse_amount(params["amount"]),
      budget_id: params["budget_id"]
    }

    case Transactions.create_transaction(attrs) do
      {:ok, %{transaction: _transaction, budget_update: _budget}} ->
        transactions_page = Transactions.list_transactions()
        {:noreply,
         socket
         |> assign(:transactions, transactions_page.entries)
         |> assign(:page_number, transactions_page.page_number)
         |> assign(:total_pages, transactions_page.total_pages)
         |> assign(:new_transaction_form, false)
         |> assign(:form_errors, nil)}

      {:error, :transaction, changeset, _} ->
        error_messages = extract_error_messages(changeset)

        {:noreply,
         socket
         |> assign(:form_errors, error_messages)}
    end
  end

  defp parse_amount(nil), do: nil
  defp parse_amount(amount) when is_binary(amount) do
    case Float.parse(amount) do
      {float_value, _remainder} -> float_value
      :error -> String.to_integer(amount) * 1.0
    end
  end

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
end
