defmodule Spring83.Boards do
  use GenServer
  require Logger
  @name :board

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def init(_) do
    path = Application.fetch_env!(:spring83, :boardfile)
    Path.dirname(path) |> File.mkdir_p!()

    table = String.to_atom(path)
    :dets.open_file(table, type: :set)
    {:ok, table}
  end

  def save(id, board), do: GenServer.cast(@name, {:save, id, board})

  def handle_cast({:save, id, board}, table) do
    :dets.insert(table, {id, NaiveDateTime.utc_now(), board})
    :dets.sync(table)
    {:noreply, table}
  end

  def difficulty(), do: GenServer.call(@name, :difficulty)
  def save_now!(id, board), do: GenServer.call(@name, {:save_now, id, board})
  def all(), do: GenServer.call(@name, :all)
  def get(id), do: GenServer.call(@name, {:get, id})

  def handle_call(:difficulty, from, table) do
    count = :dets.info(table)[:size]
    difficulty = (count / 10_000_000) ** 4
    GenServer.reply(from, difficulty)
    {:reply, table, table}
  end

  def handle_call({:save_now, id, board}, _, table) do
    :ok = :dets.insert(table, {id, NaiveDateTime.utc_now(), board})
    :ok = :dets.sync(table)
    {:reply, table, table}
  end

  def handle_call(:all, _, table) do
    # well this is silly, erlang
    all_records =
      :dets.foldl(fn elem, acc -> [elem | acc] end, [], table)
      |> Enum.map(fn {pubk, _ts, body} ->
        {Base.encode16(pubk), body}
      end)

    {:reply, all_records, table}
  end

  def handle_call({:get, id}, _, table) do
    [{_id, _ts, html}] = :dets.lookup(table, id)
    {:reply, html, table}
  end
end
