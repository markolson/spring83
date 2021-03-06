defmodule Spring83.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Spring83.CowboyServer,
      Spring83.Boards,
      Spring83.KeyGenerator
    ]

    opts = [strategy: :one_for_one, name: Spring83.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
