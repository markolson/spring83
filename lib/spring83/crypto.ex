defmodule Spring83.Crypto do
  @max_sig 2 ** 256 - 1

  @doc """
    Determine if a key meets the minimum difficulty in order to publish based on the
    current network statistics
  """
  @spec strong_enough?(integer(), float()) :: boolean()
  def strong_enough?(key, difficulty) do
    threshold = @max_sig * (1.0 - difficulty)
    key < threshold
  end

  @doc """
    Validates a provided key against the date requirements

    # EXAMPLES
      iex> Spring83.Crypto.well_formed?(2023, "1c6ffef2825b294274478bad8c80a7a610d38245a9fded18cd004c4a67ED2023")
      false
      iex> Spring83.Crypto.well_formed?(2022, "1c6ffef2825b294274478bad8c80a7a610d38245a9fded18cd004c4a67ED2023")
      true
      iex> Spring83.Crypto.well_formed?(2023, "1c6ffef2825b294274478bad8c80a7a610d38245a9fded18cd004c4a67ED2023")
      true
      iex> Spring83.Crypto.well_formed?(2024, "1c6ffef2825b294274478bad8c80a7a610d38245a9fded18cd004c4a67ED2023")
      false
      iex> Spring83.Crypto.well_formed?(2024, "1c6ffef2825b294274478bad8c80a7a610d38245a9fded18cd004c4a67ex2023")
      false
  """
  @spec well_formed?(integer() | String.t(), binary()) :: boolean()
  def well_formed?(year, key) when is_integer(year) do
    well_formed?(to_string(year), key) || well_formed?(to_string(year + 1), key)
  end

  def well_formed?(year, <<_::binary-size(58), "ED", year::binary-size(4)>> = _key)
      when is_binary(year) do
    true
  end

  def well_formed?(_, _), do: false

  # @spec sign(String.t(), String.t()) :: String.t()
  def sign(body, private_key) do
    :crypto.sign(:eddsa, :ed25519, body, [private_key, :ed25519])
  end

  # @spec verify(String.t(), String.t(), String.()) :: boolean()
  def verify(body, signature, public_key) do
    :crypto.verify(:eddsa, :ed25519, body, signature, [public_key, :ed25519])
  end
end
