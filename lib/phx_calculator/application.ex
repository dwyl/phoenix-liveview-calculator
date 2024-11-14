defmodule PhxCalculator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhxCalculatorWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phx_calculator, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhxCalculator.PubSub},
      # Start a worker by calling: PhxCalculator.Worker.start_link(arg)
      # {PhxCalculator.Worker, arg},
      # Start to serve requests, typically the last entry
      PhxCalculatorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxCalculator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhxCalculatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
