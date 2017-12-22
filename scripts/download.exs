require IEx

alias FileSync.Boundaries.DropBox.HttpApi
alias FileSync.Boundaries.DropBox.Endpoints.Download

opts = %{
  endpoint: %Download{path: "something"}
}

response = HttpApi.post(opts)

IEx.pry
