defmodule FileSync.Boundaries.FileSystem.Options do
  defstruct [
    :directory, # Base path of source's directory
    :file_system, # The module to open the file, defaults to `File`
    :io # The module used for IO, defaults to `IO`
  ]
end
