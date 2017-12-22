require IEx

alias FileSync.Boundaries.DropBox.HttpApi
alias FileSync.Boundaries.DropBox.Endpoints.Download

opts = %{
  endpoint: %Download{path: "/harrison birth/img_0305.jpg"}
}

response = HttpApi.post(opts)

IEx.pry
