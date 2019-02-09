Code.require_file "mock_logger.exs", "spec"

defmodule FileSync.Boundaries.DropBox.SyncStrategies.PaginateSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.Source
  alias FileSync.Actions.Queue
  alias FileSync.Boundaries.DropBox.SyncStrategies.Paginate
  alias FileSync.Boundaries.DropBox.{
    Client,
    Response,
    Endpoints,
    ResponseParsers,
    Options
  }

  alias FileSync.Spec.MockLogger

  context "Given we are checking for DropBox inventory" do
    let mock_logger: MockLogger.get_mock()

    let :check do
      last_response()
      |> Paginate.check(
        source(),
        queue(),
        %{
          client: mock_client(),
        }
      )
    end

    let queue: Queue.start_link |> elem(1)

    let :source do
      %Source{
        opts: %Options{
          strategy_opts: strategy_opts(),
          token: "bar"
        },
        logger: mock_logger()
      }
    end

    let :strategy_opts do
      %Paginate{
        folder: "foo",
        limit: 5,
      }
    end

    let :mock_client do
      Client
      |> double
      |> allow(:request, fn(
                 %{folder: "foo", limit: 5, token: "bar"},
                 Endpoints.ListFolder,
                 ResponseParsers.ListFolder
               ) ->
        {:ok,  %Response{
            body: %{
              entries: ["foo", "bar"],
              cursor: "ABC",
              has_more: false
            }
          }
        }
      end)
      |> allow(:request, fn(
                 %{cursor: "ABC", token: "bar"},
                 Endpoints.ListFolderContinue,
                 ResponseParsers.ListFolder
               ) ->
        {:ok, %Response{
            body: %{
              entries: ["foo", "bar"],
              cursor: "ABC",
              has_more: false
            }
          }
        }
      end)
      |> allow(:request, fn(
                 %{cursor: "apple", token: "bar"},
                 Endpoints.ListFolderContinue,
                 ResponseParsers.ListFolder
               ) ->
        {:ok, %Response{
            body: %{
              entries: ["foo", "bar"],
              cursor: "ABC",
              has_more: false
            }
          }
        }
      end)
    end

    context "with no data" do
      let last_response: %{}

      context "and the request is successful" do

        it "requests a list of a folder from the client" do
          check()
          assert_received({:request,
                          %{folder: "foo", limit: 5, token: "bar"},
                          Endpoints.ListFolder,
                          ResponseParsers.ListFolder
                        })
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
          |> allow(:request, fn(_opts, _endpoint, _parser) ->
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

    context "with a last response that has_more" do
      let :last_response do
        %{
          cursor: "ABC",
          has_more: true
        }
      end

      it "requests a continue on list_folder with the cursor" do
        check()
        assert_received({:request,
                        %{cursor: "ABC", token: "bar"},
                        Endpoints.ListFolderContinue,
                        ResponseParsers.ListFolder
                      })
      end
    end

    context "without a last response but with a cursor in the strategy opts" do
      let last_response: %{}

      let :strategy_opts do
        %Paginate{
          folder: "blah",
          limit: 3,
          cursor: "apple"
        }
      end

      it "requests a continue on list_folder with the cursoe" do
        check()
        assert_received({:request,
                        %{cursor: "apple", token: "bar"},
                        Endpoints.ListFolderContinue,
                        ResponseParsers.ListFolder
                      })

      end
    end
  end
end
