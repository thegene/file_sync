defmodule FileSync.Boundaries.DropBox.Endpoints.DownloadSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Endpoints.Download

  context "Given options for the download endpoint" do
    let options: %Download{ path: "foo.txt" }

    it "transforms into an encoded payload" do
      Download.endpoint_options(options())
      |> expect
      |> to(eq("{\"path\":\"foo.txt\"}"))
    end
  end
end
