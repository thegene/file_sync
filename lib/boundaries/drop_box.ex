defmodule FileSync.Boundaries.DropBox do
  alias FileSync.Boundaries.DropBox

  def inventory(), do: DropBox.Inventory

  def file_contents(), do: DropBox.FileContents
end
