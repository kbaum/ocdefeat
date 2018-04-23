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

  def self.by_obsession(the_obsession_id)
    self.where(obsession_id: the_obsession_id)
  end

  def self.by_title(the_title)
    self.find_by(title: the_title)
  end

  def self.by_theme(theme_name)
    self.where("obsession_id IN (?)", Theme.find_by(name: theme_name).obsession_ids)
  end

  def self.by_patient(patient_id)
    plans = User.find(patient_id).plans
    if plans.empty? # if the user's collection of plans is empty
      nil
    else
      plans
    end
  end
end
