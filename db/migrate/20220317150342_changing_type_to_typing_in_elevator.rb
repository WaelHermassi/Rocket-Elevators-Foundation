class ChangingTypeToTypingInElevator < ActiveRecord::Migration[5.2]
  def change
    remove_column :elevators, :type, :string
    add_column :elevators, :typing, :string
  end
end
