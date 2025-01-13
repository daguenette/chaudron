defmodule ChaudronWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use ChaudronWeb, :controller` and
  `use ChaudronWeb, :live_view`.
  """
  use ChaudronWeb, :html

  embed_templates "layouts/*"

  def on_mount(:default, _params, _session, socket) do
    current_path =
      case socket.private do
        %{conn: %{request_path: path}} -> path
        %{phoenix_live_view: {_view, action}} -> action[:request_path] || "/"
        _ -> "/"
      end

    {:cont,
     socket
     |> assign(:current_path, current_path)
     |> assign(:show_mobile_menu, false)}
  end
end
