defmodule FileSync.Boundaries.DropBox do
  alias FileSync.Boundaries.DropBox

  defstruct inventory: DropBox.Inventory,
            file_contents: DropBox.FileContents
end
