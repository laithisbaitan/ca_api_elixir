defmodule CaApiElixir.Authentication.Auth do

  @base_url Application.compile_env!(:ca_api, :collective_access_base_url)

  @doc """
  Return token from the session if it exists or create a new one
  ## Example
  iex> get_auth_token(conn)
  {:ok, "1bc38637e3e89e50eadb6611c29c05d6f6ce87428e5a49a14b8150139d48b88b"}
  iex> get_auth_token(conn)
  {:error, :authentication_failed}
  """
  def get_auth_token(conn) do
    case get_session(conn, :auth_token) do
      nil -> authenticate(conn)
      token -> {:ok, token}
    end
  end

  defp authenticate(conn) do
    user = Application.fetch_env!(:ca_api, :ca_service_api_user)
    key = Application.fetch_env!(:ca_api, :ca_service_api_key)

    auth_url = "#{@base_url}/service.php/auth/login"
    case HTTPoison.get(auth_url, [], [hackney: [basic_auth: {user, key}]]) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case extract_token_from_response(body) do
          {:ok, token} ->
            put_session(conn, :auth_token, token)
            {:ok, token}

          {:error, reason} -> {:error, reason}
        end

      {:error, reason} ->
        raise "Authentication failed: #{inspect(reason)}"
        {:error, :authentication_failed}
    end
  end

  # Extract authToken from
  # {"ok":true, "authToken":"token example"}
  defp extract_token_from_response(body) do
    case Jason.decode(body) do
      {:ok, %{"authToken" => token}} -> {:ok, token}
      _ -> {:error, :invalid_token}
    end
  end

  def reauthenticate(conn) do
    conn
    |> delete_session(:auth_token)
    |> authenticate()
  end

  @doc """
  Clear the contents of the auth token session
  ## Example
  iex> clear_auth_token(conn)
  :ok
  """
  def clear_auth_token(conn) do
    delete_session(conn, :auth_token)
    :ok
  end
end
