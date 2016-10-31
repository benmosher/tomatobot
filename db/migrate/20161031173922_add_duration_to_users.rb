class AddDurationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :duration, :integer, default: 25
  end
end
