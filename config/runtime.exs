import Config

config :spring83,
  minimum_keycount: String.to_integer(System.get_env("GENERATE_KEYS") || "0"),
  port: String.to_integer(System.get_env("PORT") || "8383")
