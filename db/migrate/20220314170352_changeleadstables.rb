class Changeleadstables < ActiveRecord::Migration[5.2]
  def change
    remove_column :leads, :date_of_contact_request, :string
  end
end
