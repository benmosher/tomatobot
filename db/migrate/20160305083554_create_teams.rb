class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :slack_team_id
      t.string :access_token

      t.timestamps null: false
    end
  end
end
