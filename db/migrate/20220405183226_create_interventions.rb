class CreateInterventions < ActiveRecord::Migration[5.2]
  def change
    create_table :interventions do |t|
      t.integer :author
      t.integer :customer_id
      t.integer :building_id
      t.integer :battery_id
      t.integer :column_id
      t.integer :elevator_id
      t.integer :employee_id
      t.timestamp :satart_date_and_time_intervention
      t.timestamp :end_date_and_time_intervention
      t.string :result
      t.string :report
      t.string :status

      t.timestamps
    end
  end
end
