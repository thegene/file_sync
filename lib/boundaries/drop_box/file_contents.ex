defmodule FileSync.Boundaries.DropBox.FileContents do

  alias FileSync.Data.{FileData,InventoryItem,InventoryFolder}
  alias FileSync.Boundaries.DropBox.{Client,SourceMeta,ContentHashValidator}

  def get(item, opts \\ %{})
  def get(%InventoryItem{path: path}, opts) do

    client = Map.get(opts, :client, Client)
    validators = Map.get(opts, :validators, default_validators())

    client.download(%{path: path}) |> validate_all(validators)
  end

  def get(_item = %InventoryFolder{}, _opts) do
    # folder traversal not yet implemented
  end

  defp validate_all({:ok, item}, validators) do
    file_data = build_file_data(item)
    validate({:ok, file_data}, validators)
  end

  defp validate_all(response = {:error, _message}, _validators) do
    response
  end

  defp validate(file_data, []) do
    file_data
  end

  defp validate({:ok, file_data}, validators) do
    [validator | next_validators] = validators
    res = validator.valid?(file_data)
    validate(res, next_validators)
  end

  defp validate(res = {:error, _message}, _validators) do
    res
  end

  defp build_file_data(response) do
    %FileData{
      content: response.body,
      name: response.headers["file_data"]["name"],
      size: response.headers["file_data"]["size"],
      source_meta: source_meta(response)
    }
  end

  defp source_meta(response) do
    %SourceMeta{
      content_hash: response.headers["file_data"]["content_hash"]
    }
  end

  defp default_validators do
    [ContentHashValidator]
  end
end
