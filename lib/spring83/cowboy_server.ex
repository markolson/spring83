defmodule Spring83.CowboyServer do
  use GenServer
  require Logger
  @port 8383
  @routes [
    {"/heartbeat", Spring83.Server.HTTP.Heartbeat, []},
    {"/", Spring83.Server.HTTP.Difficulty, []},
    {"/:id", Spring83.Server.HTTP.Board, []}
  ]

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    dispatch = :cowboy_router.compile([{:_, @routes}])
    opts = [port: @port]

    case :cowboy.start_clear(:http, opts, %{env: %{dispatch: dispatch}}) do
      {:ok, pid} -> Logger.info("Server started at http://localhost:#{@port} [#{inspect(pid)}]")
    end

    {:ok, []}
  end
end
