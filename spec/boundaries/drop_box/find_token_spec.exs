defmodule FileSync.Boundaries.DropBox.FindTokenSpec do
  use ESpec

  import Double

  alias FileSync.Boundaries.DropBox

  context "Given a DropBox options struct" do
    let options: struct(DropBox.Options, struct_opts())
    let dependencies: %{}

    context "when we find the token in it" do
      let resolved: options() |> DropBox.FindToken.find(dependencies())

      context "when there is already a token present" do
        let struct_opts: %{token: "foo"}

        it "leaves the token alone" do
          resolved().token
          |> expect
          |> to(eq("foo"))
        end
      end

      context "when there is no token but a token filepath" do
        let struct_opts: %{token_file_path: "tmp/foo"}
        let dependencies: %{file: mock_file()}

        let :mock_file do
          File
          |> double
          |> allow(:read!, fn("tmp/foo") -> "bar\n" end)
        end

        it "finds the token in the provided file path" do
          resolved().token
          |> expect
          |> to(eq("bar"))
        end
      end
    end
  end
end
