defmodule Spring83.Server.HTTP.Board do
  alias Spring83.Boards

  @headers %{
    "Spring-Version" => "83",
    "Content-Type" => "text/html;charset=utf-8"
  }

  @doc """
  Servers should respond to GETs for this key with an ever-changing board, generated internally, with a timestamp set to the time of the request. 
  This board is provided to help client developers understand and troubleshoot their applications.
  """
  def init(
        %{
          path: "/fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983",
          method: "GET"
        } = request,
        state
      ) do
    request = :cowboy_req.reply(200, @headers, DateTime.to_iso8601(DateTime.utc_now()), request)
    {:ok, request, state}
  end

  def init(%{path: "/" <> id, method: "GET"} = request, state) do
    {http_code, body} =
      with {:ok, public_key} <- valid_base_16_thing?(id, "key"),
           html <- Boards.get(public_key) do
        {200, html}
      else
        {:error, code, html} -> {code, html}
      end

    request = :cowboy_req.reply(http_code, @headers, body, request)
    {:ok, request, state}
  end

  def init(
        %{
          path: "/" <> id,
          method: "PUT",
          has_body: true,
          headers: %{"authorization" => "Spring-83 Signature=" <> signature}
        } = request,
        state
      ) do
    # :ok <- valid_header_datetime?()
    # :ok <- valid_meta_tag_datetime?()
    {http_code, body} =
      with {:ok, body} <- valid_body?(request),
           {:ok, public_key} <- valid_base_16_thing?(id, "key"),
           {:ok, signature} <- valid_base_16_thing?(signature, "signature"),
           :ok <- key_still_valid?(id),
           # If the signature is not valid, the client must drop the response and remove the server from its list of trustworthy peers. 
           # TODO: Harsh, but ok..
           :ok <- difficult_enough_signature?(signature),
           :ok <- valid_signature?(body, public_key, signature) do
        Boards.save_now!(public_key, body)
        {202, "hello"}
      else
        {:error, http_code, body} -> {http_code, body}
      end

    request = :cowboy_req.reply(http_code, @headers, body, request)
    {:ok, request, state}
  end

  defp valid_body?(request) do
    {:ok, body, _} = :cowboy_req.read_body(request)
    if String.length(body) > 2217, do: {:error, 413, "Contents are too long"}, else: {:ok, body}
  end

  defp valid_base_16_thing?(x, key) do
    case Base.decode16(x) do
      {:ok, b_key} -> {:ok, b_key}
      _ -> {:error, 401, "Could not parse #{key}"}
    end
  end

  defp key_still_valid?(key) do
    if Spring83.Crypto.well_formed?("2022", key),
      do: :ok,
      else: {:error, 401, "Expired or Invalid key"}
  end

  # TODO, obvs.
  defp difficult_enough_signature?(_key) do
    :ok
  end

  defp valid_signature?(body, id, signature) do
    if Spring83.Crypto.verify(body, signature, id) do
      :ok
    else
      {:error, 401, "Invalid Signature for Key #{id}"}
    end
  end
end
