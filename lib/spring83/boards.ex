defmodule Spring83.Boards do
  use GenServer
  require Logger
  @name :board

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def init(_) do
    path = Application.fetch_env!(:spring83, :boardfile)
    Path.dirname(path) |> File.mkdir_p!
    :dets.open_file(String.to_atom(path), type: :set)
  end

  def difficulty(), do: GenServer.call(@name, :difficulty)

  def handle_call(:difficulty, from, table) do
    count = :dets.info(table)[:size]
    difficulty = (count / 10_000_000) ** 4
    GenServer.reply(from, difficulty)
    {:noreply, table}
  end
end
