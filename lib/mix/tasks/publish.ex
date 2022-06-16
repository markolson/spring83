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

  @requirements ["app.start"]
  def run([html_path, server]) do
    with {:ok, html, last_updated} <- valid_html(html_path),
         #  {:ok, html, last_updated} <- enforce_meta_tag(html),
         {:ok, public_key, private_key} <- extract_keys(html_path),
         signature <- Spring83.Crypto.sign(html, private_key),
         {:ok, %{status_code: 202}} <-
           Spring83.Publisher.Board.publish(server, public_key, html, last_updated, signature) do
      Logger.info("Published at #{Path.join([server, public_key])}")
    else
      error -> Logger.error(inspect(error))
    end
  end

  defp valid_html(html_path) do
    if String.ends_with?(html_path, ".html") do
      # TODO: some Floki stuff I guess. Check for or inject the meta tag..
      {:ok, File.read!(html_path), File.stat!(html_path).mtime}
    else
      {:bad_extension, html_path}
    end
  end

  defp extract_keys(html_path) do
    public_key = keypath(html_path)

    if File.exists?(public_key) do
      {:ok, Path.basename(public_key), Base.decode16!(File.read!(public_key))}
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
