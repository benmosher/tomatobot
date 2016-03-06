class User < ActiveRecord::Base
  has_many :tasks

  validates :name, presence: true
  validates :slack_id, presence: true, uniqueness: true
end
