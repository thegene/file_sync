defmodule FileSync.Boundaries.DropBox.Endpoints.ListFolderSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Endpoints.ListFolder

  context "Given a set of options for folder api requests" do
    let options: %ListFolder{
      folder: "foo_bar"
    }

    it "gives an encoded json representation including defaults and folder" do
      ListFolder.endpoint_options(options())
      |> expect
      |> to(eq("{\"recursive\":false,\"path\":\"/foo_bar\",\"include_mounted_folders\":true,\"include_media_info\":false,\"include_has_explicit_shared_members\":false,\"include_deleted\":false}"))
    end
  end
end
