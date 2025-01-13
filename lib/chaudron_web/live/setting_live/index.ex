defmodule ChaudronWeb.SettingLive.Index do
  use ChaudronWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Settings")
      |> assign(:current_path, "/settings")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Settings</h1>
    </div>
    """
  end
end
