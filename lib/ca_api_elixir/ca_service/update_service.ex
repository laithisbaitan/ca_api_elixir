defmodule CaApiElixir.CaService.UpdateService do
  alias CaApiElixir.CaService.BaseServiceClient

  @doc """
  Update an item in a table.
  ## Examples
      iex> update("ca_objects", %{name: "Test name"}, 1, "building")
      {:ok, %HTTPoison.Response{...}}
  """
  def update(table, type_id, id, attributes) do
    BaseServiceClient.request("item", :put, table, %{id: id, attributes: attributes, type_id: type_id})
  end
end
