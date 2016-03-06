class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :slack_id
      t.string :name

      t.timestamps null: false
    end
    add_index :users, :slack_id, unique: true
  end
end
