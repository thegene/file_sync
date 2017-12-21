defmodule FileSync.Boundaries.DropBox.DownloadOptionsSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.DownloadOptions

  context "Given options for the download endpoint" do
    let options: %DownloadOptions{ path: "foo.txt" }

    it "transforms into an encoded payload" do
      DownloadOptions.endpoint_options(options())
      |> expect
      |> to(eq("{\"path\":\"foo.txt\"}"))
    end
  end
end
