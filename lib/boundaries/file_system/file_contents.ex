defmodule FileSync.Boundaries.FileSystem.FileContents do
  def put(file_data, opts) do
    file_system = Map.get(opts, :file_system, File)
    io = Map.get(opts, :io, IO)
    base_path = opts.directory

    Path.join(base_path, file_data.name)
      |> open_file(file_system)
      |> write_to_file(io, file_data.content)
      |> close_file(file_system)
  end

  defp open_file(full_path, file_system) do
    file_system.open(full_path, [:write])
  end

  defp write_to_file({:ok, file}, io, content) do
    {io.write(file, content), file}
  end

  defp close_file({:ok, file}, file_system) do
    file_system.close(file)
  end
end
