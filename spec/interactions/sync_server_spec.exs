defmodule FileSync.Interactions.SyncServerSpec do
  use ESpec
  require IEx

  alias FileSync.Interactions.SyncServer
  alias FileSync.Interactions.Source
  alias FileSync.Boundaries.{DropBox, FileSystem}

  import Double

  context "Given a source and a target source" do
    let subject: SyncServer.start_link(source: source(), target: target()) |> elem(1)
    let children: subject() |> Supervisor.which_children

    let source: %Source{
      inventory: mock_inventory(),
      opts: source_opts(),
      contents: mock_db_contents(),
      validators: source_validators(),
      queue_name: :source_queue,
      logger: mock_logger()
    }

    let target: %Source{
      queue_name: :target_queue,
      contents: mock_fs_contents(),
      validators: target_validators(),
      opts: target_opts(),
      logger: mock_logger()
    }

    let source_opts: %{
      folder: "foo"
    }

    let target_opts: %FileSystem.Options{
      directory: "bar"
    }

    let mock_db_contents: %{}
    let mock_fs_contents: %{}

    let :mock_inventory do
      DropBox.Inventory
      |> double
      |> allow(:get, fn(_) -> [] end)
    end

    let :mock_logger do
      Logger
      |> double
      |> allow(:warn, fn(_) -> nil end)
      |> allow(:info, fn(_) -> nil end)
    end

    let :failing_validator do
      FileSystem.FileSizeValidator
      |> double
      |> allow(:valid?, fn(_data, _source) -> {:error, "ka-bork"} end)
    end

    let :passing_validator do
      DropBox.ContentHashValidator
      |> double
      |> allow(:valid?, fn(data, _source) -> {:ok, data} end)
    end

    let source_validators: []
    let target_validators: []

    it "monitors four children" do
      children()
      |> length
      |> expect
      |> to(eq(4))
    end
  end
end
