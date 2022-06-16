defmodule Mix.Tasks.Spring83.Publish do
  use Mix.Task
  require Logger
  @shortdoc "Push a page up to the Realm with a valid keypair"

  @impl Mix.Task
  def run([]) do
    Logger.error("You have to supply a path to an HTML file with the same name as a public key")
  end

  def run([_path]) do
    Logger.error("You have to supply a URL to a server")
  end

  # TODO: make this do... ... less.
  @doc """
    PUT /<key> HTTP/1.1
    Content-Type: text/html;charset=utf-8
    Spring-Version: 83
    If-Unmodified-Since: <date and time in HTTP format>
    Authorization: Spring-83 Signature=<signature>

    <board>
  """
  @requirements ["app.start"]
  def run([html_path, server]) do
    with {:ok, html} <- valid_html(html_path),
         {:ok, public_key, private_key} <- extract_keys(html_path),
         signature <- Spring83.Crypto.sign(html, private_key),
         {:ok, 202} <-
           Spring83.Publisher.Board.publish(server, public_key, html, signature) do
      IO.inspect([html, private_key, signature])
    else
      error -> Logger.error(inspect error)
    end
  end

  defp valid_html(html_path) do
    if String.ends_with?(html_path, ".html") do
      # TODO: some Floki stuff I guess.
      {:ok, File.read!(html_path)}
    else
      {:bad_extension, html_path}
    end
  end

  defp extract_keys(html_path) do
    public_key = keypath(html_path)

    if File.exists?(public_key) do
      {:ok, public_key, Base.decode16!(File.read!(public_key))}
    else
      {:no_key_file, public_key}
    end
  end

  defp keypath(html_path) do
    keypath = Application.fetch_env!(:spring83, :keypath)
    name = Path.basename(html_path, ".html")
    Path.join(keypath, name)
  end
end
