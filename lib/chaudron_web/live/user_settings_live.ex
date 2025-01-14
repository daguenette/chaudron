defmodule ChaudronWeb.UserSettingsLive do
  use ChaudronWeb, :live_view

  alias Chaudron.Accounts
  import ChaudronWeb.FormComponents

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl lg:flex lg:gap-x-16 lg:px-8">
      <h1 class="sr-only">Account Settings</h1>

      <aside class="flex overflow-x-auto border-b border-gray-900/5 py-4 lg:block lg:w-64 lg:flex-none lg:border-0 lg:py-20">
        <nav class="flex-none px-4 sm:px-6 lg:px-0">
          <ul role="list" class="flex gap-x-3 gap-y-1 whitespace-nowrap lg:flex-col">
            <li>
              <a href="#" class="group flex gap-x-3 rounded-md bg-gray-50 py-2 pl-2 pr-3 text-sm/6 font-semibold text-indigo-600">
                <svg class="size-6 shrink-0 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                </svg>
                Account
              </a>
            </li>
            <li>
              <a href="#" class="group flex gap-x-3 rounded-md py-2 pl-2 pr-3 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-indigo-600">
                <svg class="size-6 shrink-0 text-gray-400 group-hover:text-indigo-600" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M7.864 4.243A7.5 7.5 0 0 1 19.5 10.5c0 2.92-.556 5.709-1.568 8.268M5.742 6.364A7.465 7.465 0 0 0 4.5 10.5a7.464 7.464 0 0 1-1.15 3.993m1.989 3.559A11.209 11.209 0 0 0 8.25 10.5a3.75 3.75 0 1 1 7.5 0c0 .527-.021 1.049-.064 1.565M12 10.5a14.94 14.94 0 0 1-3.6 9.75m6.633-4.596a18.666 18.666 0 0 1-2.485 5.33" />
                </svg>
                Security
              </a>
            </li>
          </ul>
        </nav>
      </aside>

      <main class="px-4 py-16 sm:px-6 lg:flex-auto lg:px-0 lg:py-20">
        <div class="mx-auto max-w-2xl space-y-16 sm:space-y-20 lg:mx-0 lg:max-w-none">
          <div>
            <h2 class="text-base/7 font-semibold text-gray-900">Email Settings</h2>
            <p class="mt-1 text-sm/6 text-gray-500">Update your email address and notification preferences.</p>

            <dl class="mt-6 divide-y divide-gray-100 border-t border-gray-200 text-sm/6">
              <div class="py-6 sm:flex">
                <dt class="font-medium text-gray-900 sm:w-64 sm:flex-none sm:pr-6">Email address</dt>
                <dd class="mt-1 flex justify-between gap-x-6 sm:mt-0 sm:flex-auto">
                  <div class="text-gray-900">{@current_email}</div>
                  <button type="button" class="font-semibold text-indigo-600 hover:text-indigo-500" phx-click="edit_email">
                    Update
                  </button>
                </dd>
              </div>
            </dl>
          </div>

          <div>
            <h2 class="text-base/7 font-semibold text-gray-900">Password</h2>
            <p class="mt-1 text-sm/6 text-gray-500">Ensure your account is using a secure password.</p>

            <dl class="mt-6 divide-y divide-gray-100 border-t border-gray-200 text-sm/6">
              <div class="py-6 sm:flex">
                <dt class="font-medium text-gray-900 sm:w-64 sm:flex-none sm:pr-6">Password</dt>
                <dd class="mt-1 flex justify-between gap-x-6 sm:mt-0 sm:flex-auto">
                  <div class="text-gray-900">••••••••</div>
                  <button type="button" class="font-semibold text-indigo-600 hover:text-indigo-500" phx-click="edit_password">
                    Update
                  </button>
                </dd>
              </div>
            </dl>
          </div>

          <div>
            <h2 class="text-base/7 font-semibold leading-7 text-red-600">Delete Account</h2>
            <p class="mt-1 text-sm/6 text-gray-500">
              Permanently remove your account and all of its contents from our platform. This action is not reversible.
            </p>

            <div class="mt-6 flex border-t border-gray-100 pt-6">
              <button type="button" class="text-sm/6 font-semibold text-red-600 hover:text-red-500" phx-click="show_delete_confirmation">
                Delete account
              </button>
            </div>
          </div>
        </div>
      </main>

      <%= if @show_email_modal do %>
        <div class="modal-backdrop"></div>
        <div class="modal-container">
          <div class="modal-content-wrapper">
            <div class="modal-panel">
              <.modal_close_button />
              <div class="modal-body">
                <div class="modal-content">
                  <h3 class="modal-title">Update Email</h3>
                  <div class="modal-form-container">
                    <.simple_form
                      for={@email_form}
                      id="email_form"
                      phx-submit="update_email"
                      phx-change="validate_email"
                      class="space-y-8"
                    >
                      <div>
                        <.input field={@email_form[:email]} type="email" label="Email address" required />
                      </div>
                      <div>
                        <.input
                          field={@email_form[:current_password]}
                          name="current_password"
                          id="current_password_for_email"
                          type="password"
                          label="Current password"
                          value={@email_form_current_password}
                          required
                        />
                      </div>
                      <.form_actions text="Update Email" />
                    </.simple_form>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <%= if @show_password_modal do %>
        <div class="modal-backdrop"></div>
        <div class="modal-container">
          <div class="modal-content-wrapper">
            <div class="modal-panel">
              <.modal_close_button />
              <div class="modal-body">
                <div class="modal-content">
                  <h3 class="modal-title">Change Password</h3>
                  <div class="modal-form-container">
                    <.simple_form
                      for={@password_form}
                      id="password_form"
                      action={~p"/users/log_in?_action=password_updated"}
                      method="post"
                      phx-change="validate_password"
                      phx-submit="update_password"
                      phx-trigger-action={@trigger_submit}
                      class="space-y-8"
                    >
                      <input type="hidden" name={@password_form[:email].name} value={@current_email} />
                      <div>
                        <.input field={@password_form[:password]} type="password" label="New password" required />
                      </div>
                      <div>
                        <.input
                          field={@password_form[:password_confirmation]}
                          type="password"
                          label="Confirm new password"
                        />
                      </div>
                      <div>
                        <.input
                          field={@password_form[:current_password]}
                          name="current_password"
                          type="password"
                          label="Current password"
                          id="current_password_for_password"
                          value={@current_password}
                          required
                        />
                      </div>
                      <.form_actions text="Update Password" />
                    </.simple_form>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <%= if @show_delete_confirmation do %>
        <.delete_confirmation_form show_delete_confirmation={@show_delete_confirmation} />
      <% end %>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:show_email_modal, false)
      |> assign(:show_password_modal, false)
      |> assign(:show_delete_confirmation, false)

    {:ok, socket}
  end

  def handle_event("edit_email", _params, socket) do
    {:noreply, assign(socket, :show_email_modal, true)}
  end

  def handle_event("edit_password", _params, socket) do
    {:noreply, assign(socket, :show_password_modal, true)}
  end

  def handle_event("show_delete_confirmation", _params, socket) do
    {:noreply, assign(socket, :show_delete_confirmation, true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, socket |> assign(:show_email_modal, false) |> assign(:show_password_modal, false) |> assign(:show_delete_confirmation, false)}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply,
         socket
         |> put_flash(:info, info)
         |> assign(email_form_current_password: nil)
         |> assign(:show_email_modal, false)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply,
         socket
         |> assign(trigger_submit: true)
         |> assign(password_form: password_form)
         |> assign(:show_password_modal, false)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
