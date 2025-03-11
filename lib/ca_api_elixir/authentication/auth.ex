defmodule CaApiElixir.Authentication.Auth do
  @base_url Application.compile_env!(:ca_api, :collective_access_base_url)
  @auth_token_file Path.join(System.tmp_dir(), "ca-service-wrapper-token.txt")

  @doc """
  Returns an authentication token if it already exists; otherwise, creates a new one.
  ## Examples
      iex> get_auth_token()
      {:ok, "1bc38637e3e89e50eadb6611c29c05d6f6ce87428e5a49a14b8150139d48b88b"}

      iex> get_auth_token()
      {:error, :authentication_failed}
  """
  def get_auth_token do
    case File.exists?(@auth_token_file) do
      true -> {:ok, File.read!(@auth_token_file)}
      false -> authenticate()
    end
  end

  defp authenticate do
    user = Application.fetch_env!(:ca_api, :ca_service_api_user)
    key = Application.fetch_env!(:ca_api, :ca_service_api_key)

    auth_url = "#{@base_url}/service.php/auth/login"
    case HTTPoison.get(auth_url, [], [hackney: [basic_auth: {user, key}]]) do
      {:ok, %HTTPoison.Response{body: body}} ->
        token = extract_token_from_response(body)
        {:ok, token}

      {:error, reason} ->
        raise "Authentication failed: #{inspect(reason)}"
        {:error, :authentication_failed}
    end
  end

  # Extracts the authToken from the response body and writes it to the auth token file.
  # ## Examples
  #     iex> extract_token_from_response("{"ok":true, "authToken":"1bc38637e3e8..."}")
  #     "1bc38637e3e8..."
  #
  #     iex> extract_token_from_response("{"ok":false}")
  #     {:error, :invalid_token}
  defp extract_token_from_response(body) do
    case Jason.decode(body) do
      {:ok, %{"authToken" => token}} ->
        File.write!(@auth_token_file, token)
        token
      _ -> {:error, :invalid_token}
    end
  end

  @doc """
  Reauthenticates the user by deleting the auth token file and calling authenticate.
  ## Examples
      iex> reauthenticate()
      {:ok, "1bc38637e3e89e50eadb6611c29c05d6f6ce87428e5a49a14b8150139d48b88b"}

      iex> reauthenticate()
      {:error, :authentication_failed}
  """
  def reauthenticate do
    IO.puts("Reauthenticating...")
    File.rm!(@auth_token_file)
    authenticate()
  end

  @doc """
  Clear the contents of the auth token file
  ## Example
      iex> clear_auth_token()
      :ok
  """
  def clear_auth_token do
    File.rm!(@auth_token_file)
    :ok
  end
end
