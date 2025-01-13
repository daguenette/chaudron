defmodule ChaudronWeb.LayoutLive do
  use ChaudronWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :show_mobile_menu, false)}
  end

  def render(assigns) do
    ~H"""
    <div class="content-container">
      <div class="section-spacing">
        <div class="section-container">
          <div class="header-wrapper">
            <div class="header-content">
              <h1 class="header-title">Welcome to Chaudron</h1>
              <p class="header-description">
                Your personal budget management tool
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :show_mobile_menu, !socket.assigns.show_mobile_menu)}
  end

  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :show_mobile_menu, false)}
  end
end
