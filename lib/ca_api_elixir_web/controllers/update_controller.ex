defmodule CaApiElixirWeb.UpdateController do
  use CaApiElixirWeb, :controller
  alias CaApiElixir.CaService.UpdateService

  @doc """
  Update an item in a table.
  # Example
  ## Request Body:
      {"id": '4564', "table": "ca_entities", "type_id": "stakeholders",
      "attributes": {
          "Id": 10534023453,
          "type_id": 1,
          "StakeholderCode": "*1234567",
          "StakeholderName": "laith isbaitan",
          "Idno": "9876543",
          "Mobile": "0592345678",
          "Address": "Ramallah"
        }
      }
  ## Response on success:
      {"entity_id" => 6, "ok" => true}

  ## Response on error:
      {"error": Reason for failure}
  """
  def update_item(conn, _params) do
    %{"id" => id, "type_id" => type_id, "table" => table, "attributes" => attributes} = conn.body_params
    case UpdateService.update(table, type_id, id, attributes) do
      {:ok, results} -> json(conn, results)
      {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end
end
