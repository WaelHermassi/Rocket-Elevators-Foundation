class AddEstElevField < ActiveRecord::Migration[5.2]
  def change
    add_column :quotes, :estimated_elev, :integer
  end
end
