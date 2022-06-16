defmodule Spring83.KeyGenerator do
  alias Spring83.Crypto
  
  require Logger
  use GenServer
  @year 2022

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    directory = Application.fetch_env!(:spring83, :keypath)
    File.mkdir_p!(directory)

    GenServer.cast(__MODULE__, {:key_maintenance, @year})

    {:ok, directory}
  end

  def handle_cast({:key_maintenance, year}, directory)
      when is_integer(year) and year >= 2022 and year <= 2099 do
    prune_invalid_keys(directory)

    if needs_more_keys?(directory) do
      Logger.info("Not enough keypairs. Generating a new one.")

      do_generate(to_string(year))
      |> write!(directory)
    end

    :timer.sleep(60_000)
    GenServer.cast(__MODULE__, {:key_maintenance, @year})
    {:noreply, directory}
  end

  defp do_generate(year) do
    {public, private} = :crypto.generate_key(:eddsa, :ed25519)
    if Crypto.well_formed?(year, Base.encode16(public)) do
      {Base.encode16(public), Base.encode16(private)}
    else
      do_generate(year)
    end
  end


  defp write!({public_as_base16, private_as_base16} = _keypair, directory) do
    Path.join(directory, public_as_base16)
    |> File.write!(private_as_base16)

    Logger.info("Wrote keypair #{public_as_base16}")
  end

  def prune_invalid_keys(directory) do
    File.ls!(directory)
    |> Enum.map(fn public_key ->
      if String.length(public_key) == 64 && !Crypto.well_formed?(@year, public_key) do
        Logger.info("Deleting invalid keypaid #{public_key}")
        Path.join(directory, public_key) |> File.rm()
      end
    end)
  end

  defp needs_more_keys?(directory) do
    length(File.ls!(directory)) < Application.fetch_env!(:spring83, :minimum_keycount)
  end
end
