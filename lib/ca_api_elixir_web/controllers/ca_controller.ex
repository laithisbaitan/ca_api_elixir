defmodule CaApiElixirWeb.CaController do
  use CaApiElixirWeb, :controller

  @doc """
  Clear the authentication token.
  # Example
  ## Request
      DELETE /api/clear_token
  ## Response
      {"message": "Token cleared"}
  """
  def clear_token(conn, _params) do
    case CaApiElixir.Authentication.Auth.clear_auth_token() do
      :ok -> conn |> put_status(:ok) |> json(%{message: "Token cleared"})
    end
  end
end
