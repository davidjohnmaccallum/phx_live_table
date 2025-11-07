defmodule TableComponent.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TableComponentWeb.Telemetry,
      TableComponent.Repo,
      {DNSCluster, query: Application.get_env(:table_component, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TableComponent.PubSub},
      # Start a worker by calling: TableComponent.Worker.start_link(arg)
      # {TableComponent.Worker, arg},
      # Start to serve requests, typically the last entry
      TableComponentWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TableComponent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TableComponentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
