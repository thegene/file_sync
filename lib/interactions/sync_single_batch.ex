defmodule FileSync.Interactions.SyncSingleBatch do

  alias FileSync.Interactions.SyncItem
  alias FileSync.Data.{InventoryItem,InventoryFolder}

  require IEx

  def sync(from: from, to: to, opts: opts) do
    inventory = from.module.inventory
    opts_with_default = opts |> merge_default_opts

    from.opts
    |> inventory.get
    |> sync_inventory(from, to, opts_with_default)
  end

  defp merge_default_opts(opts) do
    %{
      logger: Logger,
      sync_module: SyncItem
    }
    |> Map.merge(opts)
  end

  defp is_item?(%InventoryItem{}), do: true
  defp is_item?(%InventoryFolder{}), do: false

  defp items_only(inventory) do
    Stream.filter(inventory, fn(item) -> is_item?(item) end)
  end

  defp sync_inventory({:error, message}, _from, _to, opts) do
    opts.logger.error("Failed to get inventory: #{message}")
  end

  defp sync_inventory({:ok, response}, from, to, opts) do
    response
    |> Map.get(:items)
    |> items_only
    |> get_contents(from)
    |> sync_items(to, opts)
  end

  defp get_contents(items, from) do
    Stream.map(items, fn(item) -> from.module.file_contents.get(item) end)
  end

  defp sync_items(items, to, opts) do
    Enum.each(items, fn(item) -> sync_item(item, to, opts) end)
  end

  defp sync_item({:ok, data}, to, opts) do
    data
    |> opts.sync_module.sync(to)
    |> handle_put_response(opts)
  end

  defp sync_item({:error, message}, _to, _opts) do
    {:error, "Failed to get contents: #{message}"}
  end

  defp handle_put_response(response, opts) do
    case response do
      {:ok, message} -> opts.logger.info(message)
      {:error, message} -> opts.logger.error(message)
    end
  end
end
