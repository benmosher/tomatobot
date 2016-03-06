class User < ActiveRecord::Base
  validates :name, presence: true
  validates :slack_id, presence: true, uniqueness: true
end
