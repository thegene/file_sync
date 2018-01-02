defmodule FileSync.Interactions.SyncSample do
  require IEx

  def sync(opts = %{from: from, from_opts: from_opts}) do
    inventory = from.inventory()

    from_opts
    |> inventory.get
    |> sync_inventory(opts)
  end

  defp sync_inventory({:error, message}, _opts) do
    raise "Failed to get inventory: #{message}"
  end

  defp sync_inventory({:ok, response}, opts) do
    response
    |> Map.get(:items)
    |> get_contents(opts)
    |> sync_items(opts)
  end

  defp get_contents(items, %{from: from}) do
    Enum.map(items, fn(item) -> from.file_contents.get(item) end)
  end

  defp sync_items(items, opts) do
    Enum.each(items, fn(item) -> sync_item(item, opts) end)
  end

  defp sync_item({:ok, data}, %{to: to, to_opts: to_opts}) do
    destination = to.file_contents

    data |> destination.put(to_opts)
  end

  defp sync_item({:error, message}, _opts) do
    raise "Failed to get contents: #{message}"
  end
end
