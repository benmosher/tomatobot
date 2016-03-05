class Team < ActiveRecord::Base
  validates :slack_team_id, presence: true, uniqueness: true
  validates :access_token, presence: true
end
