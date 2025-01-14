defmodule ChaudronWeb.Router do
  use ChaudronWeb, :router

  import ChaudronWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChaudronWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Default routes
  scope "/", ChaudronWeb do
    pipe_through :browser

    live_session :default,
      on_mount: [{ChaudronWeb.UserAuth, :mount_current_user}, {ChaudronWeb.Layouts, :default}] do
      live "/", BudgetLive.Index, :index
    end
  end

  # Unauthenticated routes
  scope "/", ChaudronWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ChaudronWeb.UserAuth, :redirect_if_user_is_authenticated}, {ChaudronWeb.Layouts, :default}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  # Authenticated routes
  scope "/", ChaudronWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ChaudronWeb.UserAuth, :ensure_authenticated}, {ChaudronWeb.Layouts, :default}] do
      live "/budgets", BudgetLive.Index, :index
      live "/transactions", TransactionLive.Index, :index
      live "/settings", SettingsLive.Index, :index
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  # Public routes
  scope "/", ChaudronWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ChaudronWeb.UserAuth, :mount_current_user}, {ChaudronWeb.Layouts, :default}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:chaudron, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChaudronWeb.Telemetry
    end
  end
end
