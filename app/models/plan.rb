class Plan < ApplicationRecord
  belongs_to :obsession
  has_many :steps

  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true

  def designer
    self.obsession.user
  end

  def done? # returns true if plan consists of at least 1 step and all steps are completed (step's status = 1)
    self.steps.count > 0 && self.steps.all? {|step| step.complete?}
  end
end
