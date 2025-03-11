defmodule CaApiElixir.Utils.RequestFromat do
  alias CaApiElixir.Utils.Bundle
  @base_url Application.compile_env!(:ca_api, :collective_access_base_url)

  @doc """
  Build the Search, Create, and Update URI based on the action, table, and params.
  ## Examples
      iex> build_url("find", "ca_objects", %{q: "display_label:'Test'"})
      "http://localhost/service.php/find/ca_objects?q=display_label%3A%27Test%27&noCache=1"

      iex> build_url("item", "ca_objects", %{create_item: true, "authToken" => "ajhsdkj..."})
      "http://localhost/service.php/item/ca_objects?authToken=ajhsdkj&noCache=1"

      iex> build_url("item", "ca_objects", %{id: 56, "authToken" => "ajhsdkj..."})
      "http://localhost/service.php/item/ca_objects/id/56?authToken=ajhsdkj&noCache=1"
  """
  # for search with query
  def build_url("find", table, params) do
    query_and_token = URI.encode_query(params)
    "#{@base_url}/service.php/find/#{table}?#{query_and_token}&noCache=1"
  end

  # for create of item
  def build_url("item", table, %{create_item: true} = params) do
    token = URI.encode_query(%{"authToken" => params["authToken"]})
    "#{@base_url}/service.php/item/#{table}?#{token}&noCache=1"
  end

  # for get and update of item
  def build_url("item", table, params) do
    token = URI.encode_query(%{"authToken" => params["authToken"]})
    id = params[:id]
    "#{@base_url}/service.php/item/#{table}/id/#{id}?#{token}&noCache=1"
  end

  @doc """
  Prepare the body for the request based on the action and params.
  ## Examples
      iex> prepare_body("find", %{type_id: 1})
      "%{\"bundles\" => ...}"

      iex> prepare_body("item", %{attributes: %{"item_name" => "Test"}, create_item: true})
      "%{\"intrinsic_fields\" => ..., \"preferred_labels\" => ..., \"attributes\" => ...}"

      iex> prepare_body("item", %{attributes: %{"item_name" => "Test"}})
      "%{\"intrinsic_fields\" => ..., \"preferred_labels\" => ..., \"attributes\" => ...}"
  """
  # def prepare_body("browse", _params), do: Jason.encode!(%{"criteria" => Bundle.criteria})
  def prepare_body("find", %{type_id: type_id} = _params), do: Jason.encode!(%{"bundles" => Bundle.get_bundle(type_id)})
  # for create of item
  def prepare_body("item", %{attributes: %{"item_name" => _item_name} = attributes, create_item: true} = params) do
    IO.puts("CREATING ITEM")
    Jason.encode!(%{
      "intrinsic_fields" => %{
        "type_id" => params[:type_id],
        "parent_id" => attributes["parent_id"]
      },
      "preferred_labels" => [
        %{
          "locale" => "en_US",
          "displayname" => attributes["item_name"],
          "name" => attributes["item_name"]
        }
      ],
      "attributes" =>
      attributes
        |> Enum.map(fn {key, value} ->
          {key, [%{"locale" => "en_US", key => value}]}
        end)
        |> Enum.into(%{})
    })
  end

  # for update of item
  def prepare_body("item", %{attributes: attributes} = params) do
    # check if parent_id is in the attributes and add it to the intrinsic_fields
    intrinsic_fields =
      %{"type_id" => params[:type_id]}
      |> then(fn fields ->
        if Map.has_key?(attributes, "parent_id") do
          Map.put(fields, "parent_id", attributes["parent_id"])
        else
          fields
        end
      end)
    # combine the intrinsic_fields and attributes into the body
    base_body = %{
      "intrinsic_fields" => intrinsic_fields,
      "attributes" =>
        attributes
        |> Enum.map(fn {key, value} ->
          {key, [%{"locale" => "en_US", key => value}]}
        end)
        |> Enum.into(%{})
    }
    # check if item_name is in the attributes and add preferred_labels to the body
    body =
      if Map.has_key?(attributes, "item_name") do
        Map.put(base_body, "preferred_labels", [
          %{
            "locale" => "en_US",
            "displayname" => attributes["item_name"],
            "name" => attributes["item_name"]
          }
        ])
      else
        base_body
      end

    Jason.encode!(body)
  end

  def prepare_body("item", %{type_id: _type_id} = _params), do: "" # no body needed will return full item

end
