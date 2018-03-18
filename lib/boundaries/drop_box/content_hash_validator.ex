defmodule FileSync.Boundaries.DropBox.ContentHashValidator do
  require IEx
  
  alias FileSync.Data.FileData
  alias FileSync.Boundaries.DropBox.SourceMeta

  def valid?(data = %FileData{
                       content: content,
                       name: name,
                       source_meta: %SourceMeta{content_hash: hash}}) do
    IEx.pry
  end

end
