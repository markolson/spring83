defmodule Spring83.Publisher.Board do
  @doc """
    PUT /<key> HTTP/1.1
    Content-Type: text/html;charset=utf-8
    Spring-Version: 83
    If-Unmodified-Since: <date and time in HTTP format>
    Authorization: Spring-83 Signature=<signature>

    <board>
  """
  def publish(server, public_key, html, file_mtime, signature) do
    url = Path.join(server, public_key)

    dt =
      NaiveDateTime.from_erl!(file_mtime)
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.to_iso8601()

    case(
      HTTPoison.put(url, html, [
        {"Spring-Version", "83"},
        {"If-Unmodified-Since", dt},
        {"Authorization", "Spring-83 Signature=#{Base.encode16(signature)}"}
      ])
    ) do
      resp -> resp
    end
  end
end
