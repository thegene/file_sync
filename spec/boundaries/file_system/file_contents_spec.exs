defmodule FileSync.Boundaries.FileSystem.FileContentsSpec do
  use ESpec

  alias FileSync.Boundaries.FileSystem.{FileContents,Options}
  alias FileSync.Data.FileData

  import Double

  context "Given we have a file data object" do
    let :content, do: 'some binary data'

    let file_data: %FileData{content: content(), name: "baz.txt"}

    context "when writing this data to a local directory" do
      let :subject, do:
        FileContents.put(
                         file_data(),
                         %Options{
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
          |> allow(:binwrite, fn("SOME PID", _) -> :ok end)

        it "returns an :ok" do
          {:ok, data} = subject()
          expect(data).to eq(file_data())
        end

        it "writes to IO" do
          subject()
          assert_received({:binwrite, "SOME PID", 'some binary data'})
        end

        it "opens and closes the file" do
          subject()
          assert_received({:open, "/foo/bar/baz.txt", [:write]})
          assert_received({:close, "SOME PID"})
        end
      end

      context "when a missing file error is thrown" do
        let :mock_file_system, do:
          File
          |> double
          |> allow(:open, fn("/foo/bar/baz.txt", _opts) -> {:error, :enoent} end)

        let :mock_io, do:
          IO
          |> double
          |> allow(:write, fn(_, _) -> raise "shouldn't ever hit" end)

        it "returns the error so caller can do something with it" do
          {:error, message} = subject()
          expect(message).to eq("Could not write baz.txt: #{:enoent}")
        end
      end
    end
  end
end
