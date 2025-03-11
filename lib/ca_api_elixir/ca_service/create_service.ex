defmodule CaApiElixir.CaService.CreateService do
  alias CaApiElixir.CaService.BaseServiceClient

  @doc """
  Create a record in a table.
  ## Examples
      iex> create("ca_objects", %{name: "Test name"}, 1)
      {:ok, %HTTPoison.Response{...}}
  """
  def create(table, type_id, attributes) do
    BaseServiceClient.request("item", :put, table, %{attributes: attributes, type_id: type_id, create_item: true})
  end
end
