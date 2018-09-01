defmodule FileSync.Boundaries.DropBox.SyncStrategies.PaginateSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.Source
  alias FileSync.Actions.Queue
  alias FileSync.Boundaries.DropBox.SyncStrategies.Paginate
  alias FileSync.Boundaries.DropBox.{
    Client,
    Response
  }

  context "Given we are checking for DropBox inventory" do
    let :check do
      last_response()
      |> Paginate.check(
        source(),
        queue(),
        mock_client()
      )
    end

    let queue: Queue.start_link |> elem(1)

    let :source do
      %Source{
        opts: %{
          folder: "foo",
          limit: 5
        }
      }
    end

    context "with no data" do
      let last_response: %{}

      context "and the request is successful" do
        let :mock_client do
          Client
          |> double
          |> allow(:list_folder, fn(%{folder: "foo", limit: 5}) ->
            {:ok,  %Response{
                body: %{
                  entries: ["foo", "bar"],
                  cursor: "ABC",
                  has_more: false
                }
              }
            }
          end)
        end

        it "requests a list of a folder from the client" do
          check()
          assert_received({:list_folder, %{folder: "foo", limit: 5}})
        end

        it "returns the cursor and has_more boolean" do
          check()
          |> expect
          |> to(eq({:ok, %{
            cursor: "ABC",
            has_more: false
          }}))
        end

        it "enqueues the entries" do
          check()

          queue()
          |> Queue.pop
          |> expect
          |> to(eq("foo"))

          queue()
          |> Queue.pop
          |> expect
          |> to(eq("bar"))
        end
      end

      context "and the request returns an error" do
        let :mock_client do
          Client
          |> double
          |> allow(:list_folder, fn(%{folder: "foo", limit: 5}) ->
            {:error, "Path not found"}
          end)
        end

        it "does not enqueue anything" do
          check()
          queue()
          |> Queue.empty?
          |> expect
          |> to(eq(true))
        end

        it "returns the error" do
          check()
          |> expect
          |> to(eq({:error, "Path not found"}))
        end
      end
    end
  end
end
