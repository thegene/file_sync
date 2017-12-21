defmodule FileSync.Boundaries.DropBox.ListFolderOptionsSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.ListFolderOptions

  context "Given a set of options for folder api requests" do
    let options: %ListFolderOptions{
      folder: "foo_bar"
    }

    it "gives an encoded json representation including defaults and folder" do
      ListFolderOptions.endpoint_options(options())
      |> expect
      |> to(eq("{\"recursive\":false,\"path\":\"/foo_bar\",\"include_mounted_folders\":true,\"include_media_info\":false,\"include_has_explicit_shared_members\":false,\"include_deleted\":false}"))
    end
  end
end
