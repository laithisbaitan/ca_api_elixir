defmodule CaApi.Custom.StakeholderImporter do
  alias CaApiElixirWeb.Endpoint

  @api_url "http://10.1.1.20/archive/api/Stakeholder"
  @page_size 100

  def import_stakeholders do
    import_stakeholders(1)
  end

  defp import_stakeholders(page) do
    case fetch_stakeholders(page) do
      {:ok, stakeholders} when stakeholders != [] ->
        Enum.each(stakeholders, &insert_stakeholder/1)
        import_stakeholders(page + 1)

      _ ->
        :ok
    end
  end

  defp fetch_stakeholders(page) do
    url = "#{@api_url}?page=#{page}&pageSize=#{@page_size}"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp insert_stakeholder(%{"StakeholderCode" => code, "StakeholderName" => name, "Idno" => id, "Mobile" => mobile, "Address" => address}) do
    params = %{
      "type_id" => "stakeholder",
      "entity_name" => name,
      "stakeholder_code" => code,
      "stakeholder_idno" => id,
      "stakeholder_mobile" => mobile,
      "stakeholder_address" => address
    }

    url = Endpoint.url <> "/api/create/entity"
    HTTPoison.put(url, Jason.encode!(%{"params" => params}), [{"Content-Type", "application/json"}])
  end
end
