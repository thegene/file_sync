defmodule FileSync.Boundaries.FileSystem.FileContentsSpec do
  use ESpec

  alias FileSync.Boundaries.FileSystem.FileContents
  alias FileSync.Data.FileData

  import Double

  context "Given we have a file data object" do
    let :content, do: 'some binary data'

    let file_data: %FileData{content: content(), name: "baz.txt"}

    context "when writing this data to a local directory" do
      let :subject, do:
        FileContents.put(
                         file_data(),
                         %{
                           file_system: mock_file_system(),
                           io: mock_io(),
                           directory: "/foo/bar"
                         }
                       )

      context "when the destination exists" do
        let :mock_file_system, do:
          File
          |> double
          |> allow(:open, fn("/foo/bar/baz.txt", _opts) -> {:ok, "SOME PID"} end)
          |> allow(:close, fn("SOME PID") -> :ok end)

        let :mock_io, do:
          IO
          |> double
          |> allow(:write, fn("SOME PID", _) -> :ok end)

        it "returns an :ok" do
          expect(subject()).to eq(:ok)
        end

        it "writes to IO" do
          subject()
          assert_received({:write, "SOME PID", 'some binary data'})
        end

        it "opens and closes the file" do
          subject()
          assert_received({:open, "/foo/bar/baz.txt", [:write]})
          assert_received({:close, "SOME PID"})
        end
      end

      xcontext "when a missing file error is thrown" do
      end
    end
  end
end
