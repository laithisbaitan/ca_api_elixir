defmodule CaApiElixir.SearchService do
  alias CaApiElixir.BaseServiceClient

  def search(query) do
    BaseServiceClient.request("find", :get, "ca_objects", %{q: query})
  end
end
