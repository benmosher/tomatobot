class AddKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slack_token, :string
    add_column :users, :url_key, :string
    add_column :users, :timezone, :string
    add_column :users, :dnd_mode, :boolean, default: false
  end
end
