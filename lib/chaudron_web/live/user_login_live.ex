defmodule ChaudronWeb.UserLoginLive do
  use ChaudronWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex min-h-full flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <img class="mx-auto h-10 w-auto" src="https://tailwindui.com/plus/img/logos/mark.svg?color=indigo&shade=600" alt="Chaudron">
        <h2 class="mt-6 text-center text-2xl/9 font-bold tracking-tight text-gray-900">Sign in to your account</h2>
      </div>

      <div class="mt-10 sm:mx-auto sm:w-full sm:max-w-[480px]">
        <div class="bg-white px-6 py-12 shadow sm:rounded-lg sm:px-12">
          <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore" class="space-y-6">
            <div>
              <.input field={@form[:email]} type="email" label="Email address" required
                class="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6" />
            </div>

            <div>
              <.input field={@form[:password]} type="password" label="Password" required
                class="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6" />
            </div>

            <div class="flex items-center justify-between">
              <div class="flex items-center gap-3">
                <div class="flex items-center">
                  <.input field={@form[:remember_me]} type="checkbox"
                    class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600" />
                </div>
                <label for={@form[:remember_me].id} class="text-sm text-gray-900">Keep me logged in</label>
              </div>

              <div class="text-sm/6">
                <.link href={~p"/users/reset_password"} class="font-semibold text-indigo-600 hover:text-indigo-500">
                  Forgot your password?
                </.link>
              </div>
            </div>

            <div>
              <.button phx-disable-with="Signing in..." class="flex w-full justify-center rounded-md bg-indigo-600 px-3 py-1.5 text-sm/6 font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
                Sign in <span aria-hidden="true">→</span>
              </.button>
            </div>
          </.simple_form>
        </div>

        <p class="mt-10 text-center text-sm/6 text-gray-500">
          Not a member?
          <.link navigate={~p"/users/register"} class="font-semibold text-indigo-600 hover:text-indigo-500">
            Sign up for an account now
          </.link>
        </p>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
