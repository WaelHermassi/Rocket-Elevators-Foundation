class ChangingTypeToBinary < ActiveRecord::Migration[5.2]
  def change
    change_column :leads, :attached_file_stored_as_binary, :binary 
  end
end
