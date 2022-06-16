defmodule Spring83.Server.HTTP.Difficulty do
  alias Spring83.Boards

  def init(%{path: "/", method: "GET"} = request, state) do
    difficulty = Boards.difficulty()
    boards = Boards.all()

    headers = %{
      "Spring-Version" => "83",
      "Spring-Difficulty" => "#{difficulty}"
    }

    body = Enum.map(boards, fn {id, _body} -> ~s[
      <a href="/#{id}">#{id}</a>
    ] end) |> Enum.join("<br />")

    request = :cowboy_req.reply(200, headers, body, request)
    {:ok, request, state}
  end
end
