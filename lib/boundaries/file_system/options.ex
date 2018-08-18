defmodule FileSync.Boundaries.FileSystem.Options do
  defstruct [
    :directory, # Base path of source's directory
    io: IO, # The module used for IO, defaults to `IO`
    file_system: File, # The module to open the file, defaults to `File`
  ]
end
