defmodule CaApiElixir.CaService.SearchService do
  alias CaApiElixir.CaService.BaseServiceClient

  @doc """
  Search for a record in a table.
  ## Examples
      iex> search("ca_objects", "ca_object_labels.name:'Test name'")
      {:ok, %HTTPoison.Response{...}}
  """
  def search_query(table, type_id, query) do
    BaseServiceClient.request("find", :get, table, %{q: query, type_id: type_id})
  end

  @doc """
  Search for a record in a table by id.
  ## Examples
      iex> search_item("ca_objects", 1)
      {:ok, %HTTPoison.Response{...}}
  """
  def search_item(table, type_id, id) do
    BaseServiceClient.request("item", :get, table, %{id: id, type_id: type_id})
  end
end
