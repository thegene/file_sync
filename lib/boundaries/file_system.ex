defmodule FileSync.Boundaries.FileSystem do
  alias FileSync.Boundaries.FileSystem
  alias FileSync.Interactions.Source

  def default_target(target_directory) do
    %Source{
      contents: FileSystem.FileContents,
      validators: [FileSystem.FileSizeValidator],
      opts: %FileSystem.Options{directory: target_directory}
    }
  end
end
