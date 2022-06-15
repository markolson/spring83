defmodule Spring83.Boards do
  use GenServer
  require Logger
  @name :board

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def init(_) do
    :dets.open_file(:"boards.ets", type: :bag)
  end

  def count(), do: GenServer.call(@name, :count)

  def handle_call(:count, from, table) do
    GenServer.reply(from, :dets.info(table)[:size])
    {:noreply, table}
  end
end
