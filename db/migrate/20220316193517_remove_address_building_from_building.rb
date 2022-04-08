class RemoveAddressBuildingFromBuilding < ActiveRecord::Migration[5.2]
  def change
    remove_column :buildings, :address_of_building, :string
  end
end