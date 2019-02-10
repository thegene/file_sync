defmodule FileSync.Boundaries.DropBox.FindToken do
  alias FileSync.Boundaries.DropBox.Options

  def find(options = %Options{}, deps \\ %{}) do
    cond do
      options.token -> options
      options.token_file_path -> inject_token_from_file(options, deps)
    end
  end

  defp inject_token_from_file(options, deps) do
    file = Map.get(deps, :file, File)
    token = file.read!(options.token_file_path) |> String.trim
    %{options | token: token}
  end
end
