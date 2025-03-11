defmodule CaApiElixir.Utils.Bundle do
  def get_bundle(type_id) do
    case type_id do
      "item" -> object_bundles() #building files
      "247" -> craft_files()
      "182" -> court_bundles() #Court items
      "criteria" -> criteria()
      _ -> object_bundles()
    end
  end

  def object_bundles() do %{
    "ca_objects.note" => %{"convertCodesToDisplayText" => true},
    "ca_objects.unitdate.original.url" => %{"returnAsArray" => true},
    "ca_objects.Custser_Upload.original.url" => %{"returnAsArray" => true},
    "ca_objects.OBJ_TransactionType" => %{"convertCodesToDisplayText" => true},
    "ca_object_representations.media.original.url"  => %{"returnAsArray" => true},

    "ca_objects.children.preferred_labels" => %{"returnAsArray" => true},
    "ca_objects.parent.object_id" => %{"convertCodesToDisplayText" => true},
    "url" => %{"convertCodesToDisplayText" => true},

    }
  end

  def craft_files() do %{
    "ca_objects.note" => %{"convertCodesToDisplayText" => true},
    "ca_objects.unitdate.original.url" => %{"returnAsArray" => true},
    "ca_objects.Custser_Upload.original.url" => %{"returnAsArray" => true},
    }
  end

  def court_bundles() do %{
    "ca_objects.note" => %{"convertCodesToDisplayText" => true},
    "ca_objects.unitdate.original.url" => %{"returnAsArray" => true},
    "ca_objects.Custser_Upload.original.url" => %{"returnAsArray" => true},
    "ca_object_representations.media.original.url"  => %{"returnAsArray" => true},

    "ca_objects.children.preferred_labels" => %{"returnAsArray" => true},
    "ca_objects.parent.object_id" => %{"convertCodesToDisplayText" => true},
    "ca_objects.CasesTypes" => %{"convertCodesToDisplayText" => true},
  }
  end


  def criteria() do %{
    "type_facet" => [182]
    }
  end
end
