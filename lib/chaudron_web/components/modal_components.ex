defmodule ChaudronWeb.ModalComponents do
  use ChaudronWeb, :html

  def add_new_budget_modal(assigns) do
    ~H"""
    <%= if @modal_open do %>
      <div class="modal-backdrop"></div>
      <div class="modal-container">
        <div class="modal-content-wrapper">
          <div class="modal-panel">
            <.modal_close_button />
            <div class="modal-body">
              <div class="modal-content">
                <.modal_title title="Add New" selected_bucket={@selected_bucket} />
                <.modal_form selected_bucket={@selected_bucket} />
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

  def modal_title(assigns) do
    ~H"""
    <h3 class="modal-title">
      {@title} {String.capitalize(to_string(@selected_bucket))} Category
    </h3>
    """
  end

  def modal_actions(assigns) do
    ~H"""
    <div class="modal-actions">
      <button type="submit" class="modal-submit-button">
        Add Category
      </button>
      <button type="button" class="modal-cancel-button" phx-click="close_modal">
        Cancel
      </button>
    </div>
    """
  end

  def modal_form(assigns) do
    ~H"""
    <div class="modal-form-container">
      <.form for={%{}} phx-submit="save_budget" class="modal-form">
        <input type="hidden" name="bucket" value={@selected_bucket} />
        <div>
          <label for="category" class="form-label">
            Category Name
          </label>
          <div class="input-wrapper">
            <input type="text" name="category" id="category" required class="form-input" />
          </div>
        </div>
        <div>
          <label for="budget" class="form-label">
            Budget Amount
          </label>
          <div class="currency-input-wrapper">
            <div class="currency-symbol">
              <span class="text-gray-500 sm:text-sm">$</span>
            </div>
            <input
              type="number"
              name="budget"
              id="budget"
              required
              step="0.01"
              min="0"
              class="form-input-with-symbol"
            />
          </div>
          <.modal_actions />
        </div>
      </.form>
    </div>
    """
  end
end
