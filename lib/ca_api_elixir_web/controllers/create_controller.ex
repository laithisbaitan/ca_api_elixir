defmodule CaApiElixirWeb.CreateController do
  use CaApiElixirWeb, :controller
  alias CaApiElixir.CaService.CreateService

  @doc """
  Create new item in Collective access.
  # Example
  ## Request Body:
      {"table": "ca_entities", "type_id": "stakeholders",
      "attributes": {
        "item_name": "laith isbaitan",
        "ca_entities.stakeholder_code": "*1234567",
        "ca_entities.stakeholder_idno": "9876543",
        "ca_entities.stakeholder_mobile": "0592345678",
        "ca_entities.stakeholder_address": "Ramallah",
        }
      }
  ## Response on success:
      {"entity_id" => 6, "ok" => true}

  ## Response on error:
      {"error": Reason for failure}
  """
  def create_item(conn, _params) do
    %{"attributes" => attributes, "type_id" => type_id, "table" => table} = conn.body_params
    case CreateService.create(table, type_id, attributes) do
      {:ok, results} -> json(conn, results)
      {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end
end
