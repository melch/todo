class CreateSubtasks < ActiveRecord::Migration[5.0]
  def change
    create_table :subtasks do |t|
      t.string :name
      t.text :description
      t.datetime :completed_at
      t.datetime :position
      t.integer :task_id

      t.timestamps
    end
  end
end
