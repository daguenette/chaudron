defmodule ChaudronWeb.TransactionLive.Index do
  use ChaudronWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Transactions")
      |> assign(:current_path, "/transactions")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Transactions</h1>
    </div>
    """
  end
end
