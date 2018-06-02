alias FileSync.Actions.Queue

require IEx


defmodule Sup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, Sup, name: __MODULE__)
  end

  def init(_args) do
    children = [
      Supervisor.child_spec({Queue, agent: [name: :source]}, id: :source),
      Supervisor.child_spec({Queue, agent: [name: :target]}, id: :target)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

{:ok, server} = Sup.start_link

source = Queue.find_queue(:source)
target = Queue.find_queue(:target)


source |> Queue.push(:foo)
target |> Queue.push(
                     source |> Queue.pop
                   )

source |> Queue.empty? # true
target |> Queue.empty? # false

target |> Queue.pop # :foo

IEx.pry
