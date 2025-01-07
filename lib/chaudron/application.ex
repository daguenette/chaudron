defmodule Chaudron.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChaudronWeb.Telemetry,
      Chaudron.Repo,
      {DNSCluster, query: Application.get_env(:chaudron, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chaudron.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Chaudron.Finch},
      # Start a worker by calling: Chaudron.Worker.start_link(arg)
      # {Chaudron.Worker, arg},
      # Start to serve requests, typically the last entry
      ChaudronWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chaudron.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChaudronWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
