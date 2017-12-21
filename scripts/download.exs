require IEx

alias FileSync.Boundaries.DropBox.{HttpApi, DownloadOptions}

opts = %{
  endpoint: "download",
  endpoint_opts: %DownloadOptions{path: "something"}
}

response = HttpApi.post(opts)

IEx.pry
