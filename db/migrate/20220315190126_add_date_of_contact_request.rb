class AddDateOfContactRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :date_of_contact_request, :date
  end
end
