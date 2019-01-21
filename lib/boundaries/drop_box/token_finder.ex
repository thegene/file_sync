defmodule FileSync.Boundaries.DropBox.TokenFinder do
  alias FileSync.Boundaries.DropBox.Options

  def find(options = %Options{}, deps) do
    case options.token do
      nil -> find_from_file_path(options, deps)
      _ -> options
    end
  end

  defp find_from_file_path(options = %Options{token_file_path: path}, deps) do
    file = deps |> Map.get(:file, File)

    token = path
            |> file.read!
            |> String.trim

    options |> Map.merge(%{token: token})
  end
end
