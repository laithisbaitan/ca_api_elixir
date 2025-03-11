defmodule CaApiElixir.Utils.ParseResponse do
  # error response from collective access
  def parse_response(%{"errors" => error}, _type_id), do: %{"errors" => error}

  # no items were found
  def parse_response(%{"ok" => true, "total" => 0} = body, _type_id), do: body

  # list items that were found
  def parse_response(%{"results" => results, "total" => total}, type_id), do: %{"total" => total, "results" => results |> edit_key_names() |> handle_special_types(type_id)}

  # items were found or created
  # Example of body = %{"object_id" => _id, "ok" => true}
  def parse_response(%{"ok" => true} = body, _type_id) do
    case Enum.find(Map.keys(body), &String.ends_with?(&1, "_id")) do
      nil -> {:error, "No matching _id found in response: #{inspect(body)}"}
      _iem_id -> body
    end
  end


  # collection of renamed fields
  defp edit_key_names(body) do
    Enum.map(body, fn map ->
      map
      |> Enum.map(fn
        {"ca_objects.note", value} -> {"Creating_Date", value}
        {"ca_objects.CasesTypes", value} -> {"CaseType", value}
        {"ca_objects.unitdate.original.url", value} -> {"unitdate", value}
        {"ca_objects.children.preferred_labels", value} -> {"children", value}
        {"ca_objects.OBJ_TransactionType", value} -> {"transaction_type", value}
        {"ca_object_representations.media.original.url", value} -> {"media", value}
        {"ca_objects.Custser_Upload.original.url", value} -> {"Custser_Upload", value}
        {"ca_object_representations.media.large.url", value} -> {"large_media", value}

        {key, value} -> {key, value}
      end)
      |> Enum.into(%{})
    end)
  end

  # Special Cases require formatting
  defp handle_special_types(body, type_id) do
    case type_id do
      28 -> building_files_children_missing_label(body) #building files
      _ -> body
    end
  end
  defp building_files_children_missing_label(body) do
    Enum.map(body, fn map ->
      map
      |> Map.update("display_label", nil, fn
        "[BLANK]" -> Map.get(map, "transaction_type", "[NO_TRANSACTION_TYPE]")
        other -> other
      end)
    end)
  end

end
