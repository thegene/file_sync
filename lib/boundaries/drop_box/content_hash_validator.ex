defmodule FileSync.Boundaries.DropBox.ContentHashValidator do
  require IEx
  
  alias FileSync.Data.FileData
  alias FileSync.Boundaries.DropBox.SourceMeta

  def valid?(data = %FileData{
                       content: content,
                       source_meta: %SourceMeta{content_hash: hash}}) do
    content
    |> content_chunk
    |> build_hashes
    |> Enum.join
    |> make_combined_hash
    |> assert_match(hash, data)
  end

  defp assert_match(subject, expected, file_data) do
    if subject == expected do
      {:ok, file_data}
    else
      {:error, "#{file_data.name} failed dropbox content hash comparison"}
    end
  end

  defp make_combined_hash(big_hash) do
    :crypto.hash(:sha256, big_hash)
    |> Base.encode16
    |> String.downcase
  end

  defp build_hashes(chunks) do
    chunks
    |> Enum.map(fn(chunk) ->
      :crypto.hash(:sha256, chunk)
    end)
  end

  defp content_chunk(content, start \\ 0, memo \\ [])
  defp content_chunk(content, start, memo) when byte_size(content) <= start + 4194304 do
    len = byte_size(content) - start
    memo ++ [content |> binary_part(start, len)]
  end

  defp content_chunk(content, start, memo) do
    new_memo = memo ++ [content |> binary_part(start, 4194304)]

    content |> content_chunk(start + 4194304, new_memo)
  end
end
