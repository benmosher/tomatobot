class Task < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates :team, presence: true
  validates :user, presence: true

  serialize :completed, Array
  serialize :distraction, Array
end
