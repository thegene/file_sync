defmodule FileSync.Actions.Queue do
  use Agent

  def start_link(opts \\ []) do
    Agent.start_link(fn -> {} end, opts)
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
end
