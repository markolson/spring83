defmodule Spring83.Server.Difficulty do
  alias Spring83.Boards

  def init(%{path: "/", method: "GET"} = request, state) do
    difficulty = Boards.difficulty()

    headers = %{
      "Spring-Version" => "83",
      "Spring-Difficulty" => "#{difficulty}"
    }
    body = "Difficulty is #{difficulty}"

    request = :cowboy_req.reply(200, headers, body, request)
    {:ok, request, state}
  end
end
