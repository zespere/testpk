defmodule Testpk.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TestpkWeb.Telemetry,
      # Start the UserTokenCleaner
      Testpk.Repo,
      {Testpk.UserTokenCleaner, interval_minutes: 10},
      {DNSCluster, query: Application.get_env(:testpk, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Testpk.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Testpk.Finch},
      # Start a worker by calling: Testpk.Worker.start_link(arg)
      # {Testpk.Worker, arg},
      # Start to serve requests, typically the last entry
      TestpkWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Testpk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TestpkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end