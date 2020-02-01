defmodule FileSync.Boundaries.DropBox do
  alias FileSync.Boundaries.DropBox
  alias FileSync.Interactions.Source

  def build_source(%{folder: folder, limit: limit, token_file_path: token_file_path}) do
    %Source{
      contents: DropBox.FileContents,
      validators: [DropBox.ContentHashValidator],
      inventory: DropBox.Inventory,
      strategy: DropBox.SyncStrategies.Paginate,
      opts: %DropBox.Options{
        strategy_opts: %DropBox.SyncStrategies.Paginate{
          folder: folder,
          limit: limit,
        },
        token_file_path: token_file_path
      } |> DropBox.FindToken.find,
    }
  end
end
