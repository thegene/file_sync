defmodule FileSync.Boundaries.DropBox.ContentHashValidator do
  require IEx
  
  alias FileSync.Data.FileData
  alias FileSync.Boundaries.DropBox.SourceMeta

  def valid?(data = %FileData{
                       content: content,
                       name: name,
                       source_meta: %SourceMeta{content_hash: hash}}) do
    chunks = content
    |> get_chunks
  end

  defp get_chunks(content) do
    chunks = get_next_chunk(content)
    IEx.pry
  end

  defp get_next_chunk(content, start \\ 0, memo \\ [])
  defp get_next_chunk(content, start, memo) when byte_size(content) <= start + 4194304 do
    len = byte_size(content) - start
    memo ++ [content |> binary_part(start, len)]
  end

  defp get_next_chunk(content, start, memo) do
    new_memo = memo ++ [content |> binary_part(start, 4194304)]

    content |> get_next_chunk(start + 4194304, new_memo)
  end
end
