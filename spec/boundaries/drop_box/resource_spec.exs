defmodule FileSync.Boundaries.DropBox.ResourceSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Resource
  alias FileSync.Data.InventoryItem

  import Double

  context "Given an InventoryItem from dropbox" do
    let :inventory_item, do: %InventoryItem{
      name: "IMG_0225.jpg",
      size: 9349140
    }

    context "when we get the underlying resource" do
      #let :http, do:
        

      #let :subject, do: Resource.get(resource: inventory_item()i, http: http())


    end
  end
end
