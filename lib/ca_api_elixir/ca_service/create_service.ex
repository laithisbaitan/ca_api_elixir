defmodule CaApiElixir.CreateService do
  alias CaApiElixir.BaseServiceClient

  def create(params) do
    BaseServiceClient.request("item", :put, "ca_entities", %{params: params})
  end
end
