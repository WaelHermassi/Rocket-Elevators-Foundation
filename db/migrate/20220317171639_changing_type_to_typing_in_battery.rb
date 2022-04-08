class ChangingTypeToTypingInBattery < ActiveRecord::Migration[5.2]
  def change
    remove_column :batteries, :type, :string
    add_column :batteries, :typing, :string
  end
end
