defmodule Spring83.Server.HTTP.Heartbeat do
  def init(%{path: "/heartbeat", method: "GET"} = request, state) do
    request = :cowboy_req.reply(200, %{}, "OK", request)
    {:ok, request, state}
  end
end
