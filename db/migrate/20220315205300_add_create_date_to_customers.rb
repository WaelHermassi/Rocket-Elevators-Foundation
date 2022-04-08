class AddCreateDateToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :customer_creation_date, :date
    add_reference :customers, :address, foreign_key: true
  end
end
