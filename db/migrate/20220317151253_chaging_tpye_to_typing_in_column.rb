class ChagingTpyeToTypingInColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :columns, :type, :string
    add_column :columns, :typing, :string
  end
end
