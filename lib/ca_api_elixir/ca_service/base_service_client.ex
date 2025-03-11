defmodule CaApiElixir.CaService.BaseServiceClient do
  @moduledoc """
  A base module for interacting with the CollectiveAccess API.
  """
  alias CaApiElixir.Utils.{ParseResponse, RequestFromat}
  alias HTTPoison
  alias CaApiElixir.Authentication.Auth

  @doc """
  Sends a request to the CollectiveAccess API with authentication.
  ## Examples
      iex> request("find", :post, "ca_objects", %{q: "display_label:'Test'"})
      {:ok, %{"ok" => true, "total" => 0}}
  """
  def request(service, method, table, params \\ %{}, reauth_attempted \\ false) do
    # Add authToken to parameters
    {:ok, token} = Auth.get_auth_token()
    params_with_token = Map.put(params, "authToken", token)
    url = RequestFromat.build_url(service, table, params_with_token)
    body = RequestFromat.prepare_body(service, params)
    IO.inspect("REQUEST URL: #{url}")
    IO.inspect("REQUEST BODY: #{body}")

    options = [timeout: 30_000, recv_timeout: 30_000]
    #handle response from collective access
    case HTTPoison.request(method, url, body, [], options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        type_id = params[:type_id]
        IO.inspect("REQUEST RESULT: #{body}")
        {:ok, Jason.decode!(body) |> ParseResponse.parse_response(type_id)}

      {:ok, %HTTPoison.Response{status_code: 401, body: _body}} ->
        case reauth_attempted do
          false ->
            Auth.reauthenticate()
            request(service, method, table, params, true)
          true -> {:error, "Reauthentication failed"}
        end

      {:ok, %HTTPoison.Response{status_code: _, body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      unexpected ->
        {:error, unexpected}
    end
  end
end
