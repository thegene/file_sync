defmodule FileSync.Boundaries.DropBox.Endpoints.DownloadSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Endpoints.Download

  context "Given options for the download endpoint" do
    let endpoint: Download.build_endpoint(%{ path: "foo.txt" })

    it "returns headers specifying the path" do
      endpoint()
      |> Download.headers
      |> expect
      |> to(eq(["Dropbox-API-Arg": "{\"path\":\"foo.txt\"}"]))
    end

    it "returns an empty body" do
      endpoint()
      |> Download.body
      |> expect
      |> to(eq(""))
    end

    it "knows its endpoint url" do
      endpoint()
      |> Download.url
      |> expect
      |> to(eq("https://content.dropboxapi.com/2/files/download"))
    end
  end
end
