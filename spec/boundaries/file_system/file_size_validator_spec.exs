defmodule FileSync.Boundaries.FileSystem.FileSizeValidatorSpec do

  use ESpec

  import Double

  alias FileSync.Data.FileData
  alias FileSync.Interactions.Source
  alias FileSync.Boundaries.FileSystem.{FileSizeValidator,Options}

  context "Given FileData saved to an inventory" do
    let :file_contents, do:
      [
        "spec",
        "fixtures",
        "harrison_birth.jpg"
      ]
      |> Path.join
      |> File.read!

    let source: %Source{ opts: source_opts() }

    let source_opts: %Options{
      directory: "/foo/bar",
      file_system: mock_file_system()
    }

    let :file_data do
      %FileData{
        content: file_contents(),
        name: "harrison_birth.jpg",
        size: 8970555
      }
    end

    let subject: FileSizeValidator.valid?(file_data(), source())

    context "when the file sizes match up" do
      let :mock_file_system do
        File
        |> double
        |> allow(:stat, fn("/foo/bar/harrison_birth.jpg") ->
                           {:ok, %{size: 8970555}}
                        end
                )
      end

      it "returns the file_data with an :ok" do
        {:ok, data} = subject()
        expect(data).to eq(file_data())
      end
    end

    context "when it cannot find the file" do
      let :mock_file_system do
        File
        |> double
        |> allow(:stat, fn("/foo/bar/harrison_birth.jpg") ->
                          {:error, :enoent}
                        end
                )
      end

      it "returns the error message" do
        {:error, reason} = subject()
        reason
        |> expect
        |> to(eq("harrison_birth.jpg failed file size validator: received enoent"))
      end
    end

    context "when the file sizes are different" do
      let :mock_file_system do
        File
        |> double
        |> allow(:stat, fn("/foo/bar/harrison_birth.jpg") ->
                          {:ok, %{size: 0}}
                        end
                )
      end

      it "returns an error message" do
        {:error, reason} = subject()
        reason
        |> expect
        |> to(eq("harrison_birth.jpg failed file size validator: " <>
                 "expected 8970555 but found as 0"))
      end

    end
  end
end
