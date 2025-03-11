defmodule CaApiElixirWeb.SearchController do
  use CaApiElixirWeb, :controller
  alias CaApiElixir.CaService.SearchService

  @doc """
  Search for an item from CollectiveAccess using an ID.
  # Example
  ## Request Body:
      {"id": "1", "type_id": "item", "table": "ca_objects"}
  ## Response on success:
      {"ok": true, "results": [{"display_label": "label", "id":"1", "object_id":"1"}]}
  ## Response on error:
      {"error": Reason for failure}
  """
  def item_search(conn, _params) do
    %{"id" => id, "type_id" => type_id, "table" => table} = conn.body_params
    case SearchService.search_item(table, type_id, id) do
      {:ok, results} -> json(conn, results)
      {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end

  @doc """
  Search for an item from CollectiveAccess using a Query.

  # Example
  ## Request Body:
      {"table": "ca_objects",
      "type_id": "item",
      "query": ["ca_objects.OBJ_HODCODE:'19'", "ca_objects.OBJ_HAYCODE:'10'", "ca_objects.OBJ_PIECECODE:'137'"]
      }

  ## Response on success:
      {"ok": true,
      "results": [{"display_label": "label", "id":"1", "object_id":"1"}]
      }

  ## Response on error:
      {"error": Reason for failure}
  """
  def query_search(conn, _params) do
    %{"query" => json_query, "type_id" => type_id, "table" => table} = conn.body_params
    # Enum.each(json_query, &CustomQuery.check(&1))
    query_string = json_query |> Enum.join(" AND ")
    # IO.inspect(query_string)

    case SearchService.search_query(table, type_id, query_string) do
      {:ok, results} -> json(conn, results)
      {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end
end
