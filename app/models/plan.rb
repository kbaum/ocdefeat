class Plan < ApplicationRecord
  belongs_to :obsession
  has_many :steps

  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true

  def designer
    self.obsession.user
  end
end
