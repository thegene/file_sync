defmodule FileSync.Mixfile do
  use Mix.Project

  def project do
    [
      app: :file_sync,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      preferred_cli_env: [espec: :test],
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      applications: [:httpoison],
      mod: {FileSync.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:espec, "~> 1.5.0", only: :test},
      {:double, "~> 0.6.5", only: :test},
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"}
    ]
  end

  defp aliases do
    [
      test: "espec --no-start"
    ]
  end
end
