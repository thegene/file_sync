defmodule FileSync.Interactions.SyncItemSpec do
  use ESpec
  require IEx

  import Double

  alias FileSync.Data.FileData
  alias FileSync.Interactions.SyncItem
  alias FileSync.Interactions.Source

  alias FileSync.Boundaries.FileSystem

  context "Given a sync target" do
    let :target_module, do:
      %FileSystem{
        file_contents: fs_file_contents()
      }
    let target: %Source{ module: target_module(), opts: %{} }

    let subject: SyncItem.sync(file_data_response(), target())

    let :fs_file_contents, do:
      FileSystem.FileContents
      |> double
      |> allow(:put, fn(_item, _to_opts) -> put_response() end)

    let put_response: nil

    context "with a successful file data response" do
      let file_data_response: {:ok, %FileData{name: "Foo File"}}

      context "when put is successful" do
        let put_response: {:ok, "Successful"}

        it "returns a success response" do
          expect(subject()).to eq({:ok, "Foo File sync successful"})
        end
      end

      context "when put is not successful" do
        let put_response: {:error, "write error"}

        it "returns an error response" do
          expect(subject()).to eq({:error, "Foo File sync failed: write error"})
        end
      end
    end

    context "with a failed file data response" do
      let file_data_response: {:error, "file missing"}
      
      it "returns an error response" do
        expect(subject()).to eq({:error, "Item sync failed: file missing"})
      end
    end

  end
end
