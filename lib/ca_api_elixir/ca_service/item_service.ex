defmodule CaApiElixir.ItemService do
  alias CaApiElixir.BaseServiceClient

  def search(id) do
    BaseServiceClient.request("item", :get, "ca_objects", %{id: id})
  end
end
