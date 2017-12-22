require IEx

alias FileSync.Boundaries.DropBox.HttpApi
alias FileSync.Boundaries.DropBox.Endpoints.Download

opts = %{
  endpoint: "download",
  endpoint_opts: %Download{path: "something"}
}

response = HttpApi.post(opts)

IEx.pry
