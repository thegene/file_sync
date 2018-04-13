defmodule FileSync.Boundaries.FileSystem.FileContents do

  def put(file_data, opts) do
    file_system = Map.get(opts, :file_system, File)
    io = Map.get(opts, :io, IO)
    base_path = opts.directory

    Path.join(base_path, file_data.name)
      |> open_file(file_system)
      |> write_to_file(io, file_data)
      |> close_file(file_system)
      |> respond(file_data)
  end

  defp open_file(full_path, file_system) do
    file_system.open(full_path, [:write])
  end

  defp write_to_file({:ok, file}, io, file_data) do
    {io.binwrite(file, file_data.content), file}
  end

  defp write_to_file({:error, reason}, _io, _file_data) do
    {:error, reason}
  end

  defp close_file({:ok, file}, file_system) do
    file_system.close(file)
  end

  defp close_file({:error, message}, _file_system) do
    {:error, message}
  end

  defp respond(:ok, file_data) do
    {:ok, file_data}
  end

  defp respond({:error, message}, file_data) do
    {:error, "Could not write #{file_data.name}: #{message}"}
  end
end
