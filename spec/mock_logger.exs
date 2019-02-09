defmodule FileSync.Spec.MockLogger do
  import Double

  def get_mock do
    Logger
    |> double
    |> allow(:warn, fn(_msg) -> nil end)
    |> allow(:info, fn(_msg) -> nil end)
    |> allow(:error, fn(_msg) -> nil end)
  end
end
