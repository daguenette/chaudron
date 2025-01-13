defmodule ChaudronWeb.MobileMenuComponent do
  use ChaudronWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~H"""
    <div class="relative z-50 lg:hidden" role="dialog" aria-modal="true" id={@id}>
      <%= if @show_mobile_menu do %>
        <div class="fixed inset-0 z-50">
          <div
            class="fixed inset-0 bg-gray-900/80"
            aria-hidden="true"
            phx-click="close_mobile_menu"
            phx-target={@myself}
            phx-window-keydown="close_mobile_menu"
            phx-key="escape"
          >
          </div>

          <div class="fixed inset-0 flex">
            <div class="relative mr-16 flex w-full max-w-xs flex-1">
              <!-- Close button -->
              <div class="absolute left-full top-0 flex w-16 justify-center pt-5">
                <button type="button" class="-m-2.5 p-2.5" phx-click="close_mobile_menu" phx-target={@myself}>
                  <span class="sr-only">Close sidebar</span>
                  <svg
                    class="size-6 text-white"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <!-- Mobile sidebar content -->
              <div class="flex grow flex-col gap-y-5 overflow-y-auto bg-gray-900 px-6 pb-4 ring-1 ring-white/10">
                <div class="flex h-16 shrink-0 items-center">
                  <img class="h-8 w-auto" src={~p"/images/main_logo.svg"} alt="Chaudron" />
                </div>
                <nav class="flex flex-1 flex-col" phx-click-away="close_mobile_menu" phx-target={@myself}>
                  <ul role="list" class="flex flex-1 flex-col gap-y-7">
                    <li>
                      <ul role="list" class="-mx-2 space-y-1">
                        <li>
                          <.link
                            href={~p"/budgets"}
                            class={"group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold #{if @current_path == "/budgets", do: "bg-gray-800 text-white", else: "text-gray-400 hover:bg-gray-800 hover:text-white"}"}
                            phx-click="close_mobile_menu"
                            phx-target={@myself}
                          >
                            <svg
                              class={"size-6 shrink-0 #{if @current_path == "/budgets", do: "text-white", else: "text-gray-400 group-hover:text-white"}"}
                              fill="none"
                              viewBox="0 0 24 24"
                              stroke-width="1.5"
                              stroke="currentColor"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                d="M2.25 18.75a60.07 60.07 0 0115.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 013 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 00-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 01-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 003 15h-.75M15 10.5a3 3 0 11-6 0 3 3 0 016 0zm3 0h.008v.008H18V10.5zm-12 0h.008v.008H6V10.5z"
                              />
                            </svg>
                            Budgets
                          </.link>
                        </li>
                        <li>
                          <.link
                            href={~p"/transactions"}
                            class={"group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold #{if @current_path == "/transactions", do: "bg-gray-800 text-white", else: "text-gray-400 hover:bg-gray-800 hover:text-white"}"}
                            phx-click="close_mobile_menu"
                            phx-target={@myself}
                          >
                            <svg
                              class={"size-6 shrink-0 #{if @current_path == "/transactions", do: "text-white", else: "text-gray-400 group-hover:text-white"}"}
                              fill="none"
                              viewBox="0 0 24 24"
                              stroke-width="1.5"
                              stroke="currentColor"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5"
                              />
                            </svg>
                            Transactions
                          </.link>
                        </li>
                      </ul>
                    </li>
                    <li class="mt-auto">
                      <div class="text-xs/6 font-semibold text-gray-400">Account</div>
                      <ul role="list" class="-mx-2 mt-2 space-y-1">
                        <li>
                          <.link
                            href={~p"/settings"}
                            class={"group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold #{if @current_path == "/settings", do: "bg-gray-800 text-white", else: "text-gray-400 hover:bg-gray-800 hover:text-white"}"}
                            phx-click="close_mobile_menu"
                            phx-target={@myself}
                          >
                            <svg
                              class={"size-6 shrink-0 #{if @current_path == "/settings", do: "text-white", else: "text-gray-400 group-hover:text-white"}"}
                              fill="none"
                              viewBox="0 0 24 24"
                              stroke-width="1.5"
                              stroke="currentColor"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z"
                              />
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                              />
                            </svg>
                            Settings
                          </.link>
                        </li>
                      </ul>
                    </li>
                  </ul>
                </nav>
              </div>
            </div>
          </div>
        </div>
      <% end %>
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
