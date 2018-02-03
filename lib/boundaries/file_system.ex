defmodule FileSync.Boundaries.FileSystem do
  alias FileSync.Boundaries.FileSystem

  defstruct inventory: FileSystem.Inventory,
            file_contents: FileSystem.FileContents
end
