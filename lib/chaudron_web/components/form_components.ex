defmodule ChaudronWeb.FormComponents do
  use ChaudronWeb, :html

  # Form Components

  attr :form_errors, :string, default: nil
  attr :new_budget_form, :boolean, required: true
  attr :selected_bucket, :atom, required: true

  def new_budget_form(assigns) do
    assigns = assign_new(assigns, :form_errors, fn -> nil end)

    ~H"""
    <%= if @new_budget_form do %>
      <div class="modal-backdrop"></div>
      <div class="modal-container">
        <div class="modal-content-wrapper">
          <div class="modal-panel">
            <.modal_close_button />
            <div class="modal-body">
              <div class="modal-content">
                <.form_title title="Add New" selected_bucket={@selected_bucket} />
                <div class="modal-form-container">
                  <.form for={%{}} phx-submit="save_budget" class="modal-form">
                    <input type="hidden" name="bucket" value={@selected_bucket} />
                    <div>
                      <.form_label for="category" title="Category Name" />
                      <.form_input
                        type="text"
                        name="category"
                        id="category"
                        form_errors={@form_errors}
                        required={true}
                      />
                    </div>
                    <div>
                      <.form_label for="budget" title="Budget Amount" />
                      <.currency_form_input form_errors={@form_errors} required={true} />

                      <%= if @form_errors do %>
                        <div class="mt-2 text-sm text-red-600">
                          {@form_errors}
                        </div>
                      <% end %>

                      <.form_actions />
                    </div>
                  </.form>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  attr :form_errors, :string, default: nil
  attr :edit_budget_form, :boolean, required: true
  attr :budget, :map, required: true

  def edit_budget_form(assigns) do
    assigns = assign_new(assigns, :form_errors, fn -> nil end)
    assigns = assign_new(assigns, :budget, fn -> nil end)

    ~H"""
    <%= if @edit_budget_form do %>
      <div class="modal-backdrop"></div>
      <div class="modal-container">
        <div class="modal-content-wrapper">
          <div class="modal-panel">
            <.modal_close_button />
            <div class="modal-body">
              <div class="modal-content">
                <.form_title budget={@budget} />
                <div class="modal-form-container">
                  <.form for={%{}} phx-submit="update_budget" class="modal-form">
                    <input type="hidden" name="budget_id" value={@budget.id} />
                    <input type="hidden" name="bucket" value={@budget.bucket} />
                    <div>
                      <.form_label for="category" title="Category Name" />
                      <.form_input
                        type="text"
                        name="category"
                        id="category"
                        value={@budget.category}
                        form_errors={@form_errors}
                        required={false}
                      />
                    </div>
                    <div>
                      <.form_label for="budget" title="Budget Amount" />
                      <.currency_form_input
                        value={@budget.budget}
                        form_errors={@form_errors}
                        required={false}
                      />
                      <%= if @form_errors do %>
                        <div class="mt-2 text-sm text-red-600">
                          {@form_errors}
                        </div>
                      <% end %>

                      <.form_actions text="Update Category" show_delete={true} />
                    </div>
                  </.form>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  attr :show_delete_confirmation, :boolean, required: true

  def delete_confirmation_form(assigns) do
    ~H"""
    <%= if @show_delete_confirmation do %>
      <div class="modal-backdrop"></div>
      <div class="modal-container">
        <div class="modal-content-wrapper">
          <div class="modal-panel">
            <div class="modal-body p-6">
              <div class="modal-content text-center">
                <h3 class="text-lg font-semibold mb-4">Delete Budget Category</h3>
                <p class="mb-6 text-gray-600">
                  Are you sure you want to delete this category? This action cannot be undone.
                </p>
                <div class="flex justify-center space-x-4">
                  <button type="button" class="modal-delete-button" phx-click="confirm_delete">
                    Delete
                  </button>
                  <button type="button" class="modal-cancel-button" phx-click="cancel_delete">
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  def modal_close_button(assigns) do
    ~H"""
    <div class="modal-close-button-wrapper">
      <button type="button" class="modal-close-button" phx-click="close_modal">
        <span class="sr-only">Close</span>
        <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    """
  end

  attr :budget, :map, default: nil
  attr :title, :string, default: nil
  attr :selected_bucket, :atom, default: nil

  def form_title(assigns) do
    ~H"""
    <h3 class="modal-title">
      <%= if assigns[:budget] do %>
        Editing "{@budget.category}"
      <% else %>
        {@title} {String.capitalize(to_string(@selected_bucket))} Category
      <% end %>
    </h3>
    """
  end

  attr :text, :string, default: "Add Category"
  attr :show_delete, :boolean, default: false

  def form_actions(assigns) do
    assigns = assign_new(assigns, :text, fn -> "Add Category" end)
    assigns = assign_new(assigns, :show_delete, fn -> false end)

    ~H"""
    <div class="modal-actions">
      <button type="submit" class="modal-submit-button">
        {@text}
      </button>
      <%= if @show_delete do %>
        <button type="button" class="modal-delete-button" phx-click="show_delete_confirmation">
          Delete
        </button>
      <% end %>
      <button type="button" class="modal-cancel-button" phx-click="close_modal">
        Cancel
      </button>
    </div>
    """
  end

  attr :for, :string, required: true
  attr :title, :string, required: true

  def form_label(assigns) do
    ~H"""
    <label for={@for} class="form-label">
      {@title}
    </label>
    """
  end

  attr :type, :string, required: true
  attr :name, :string, required: true
  attr :id, :string, required: true
  attr :form_errors, :string, default: nil
  attr :value, :string, default: nil
  attr :required, :boolean, default: false

  def form_input(assigns) do
    assigns = assign_new(assigns, :form_errors, fn -> nil end)
    assigns = assign_new(assigns, :value, fn -> nil end)

    ~H"""
    <div class="input-wrapper">
      <input
        type={@type}
        name={@name}
        id={@id}
        {%{"required" => @required }}
        placeholder={@value}
        class={"form-input #{if @form_errors, do: "border-red-500"}"}
      />
    </div>
    """
  end

  attr :form_errors, :string, default: nil
  attr :value, :string, default: nil
  attr :required, :boolean, default: false

  def currency_form_input(assigns) do
    assigns = assign_new(assigns, :form_errors, fn -> nil end)
    assigns = assign_new(assigns, :value, fn -> nil end)

    ~H"""
    <div class="currency-input-wrapper">
      <div class="currency-symbol">
        <span class="text-gray-500 sm:text-sm">$</span>
      </div>
      <input
        type="number"
        name="budget"
        id="budget"
        step="0.01"
        min="0"
        {%{"required" => @required }}
        placeholder={format_amount(@value)}
        class={"form-input-with-symbol #{if @form_errors, do: "border-red-500"}"}
      />
    </div>
    """
  end

  defp format_amount(amount) when is_number(amount) do
    :erlang.float_to_binary(amount, decimals: 2)
  end

  defp format_amount(_), do: nil
end
