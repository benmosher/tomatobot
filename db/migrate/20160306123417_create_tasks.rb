class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :team, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.text :completed
      t.text :distraction

      t.timestamps null: false
    end
  end
end
