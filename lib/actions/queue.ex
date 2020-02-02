defmodule FileSync.Actions.Queue do
  use Agent

  def start_link(opts \\ []) do
    Agent.start_link(fn -> initial_value(opts) end, agent_opts(opts))
  end

  def empty?(queue) do
    queue |> get == {}
  end

  def push(queue, item) do
    Agent.update(queue, fn(old_queue) -> push_new_value(old_queue, item) end)
  end

  def pop(queue) do
    queue
    |> get
    |> handle_pop(queue)
  end

  def inspect(queue) do
    queue
    |> get
    |> handle_inspect
    |> Enum.reverse
  end

  def find_queue(name) do
    GenServer.whereis(name)
  end

  defp agent_opts(opts) do
    opts |> Keyword.take([:name])
  end

  defp initial_value(opts) do
    opts |> Keyword.get(:value, {})
  end

  defp push_new_value({head, tail}, item) do
    {head, {item, tail}}
  end

  defp push_new_value({}, item) do
    {item, {}}
  end

  defp handle_pop({pop, new_queue}, queue) do
    Agent.update(queue, fn(_old_queue) -> new_queue || {} end)
    pop
  end

  defp handle_pop({}, _queue) do
    nil
  end

  defp get(queue) do
    Agent.get(queue, &(&1)) 
  end

  defp handle_inspect(queue, memo \\ [])
  defp handle_inspect({head, tail}, memo) do
    handle_inspect(tail, [head | memo])
  end

  defp handle_inspect({}, memo) do
    memo
  end
end
