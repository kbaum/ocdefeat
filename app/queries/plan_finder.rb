class PlanFinder
  attr_accessor :default_scope

  def initialize(default_scope) # the patient's own plans or the therapist's patients' plans
    @default_scope = default_scope
  end

  def filter_by_obsession_targeted(scoped, obsession_targeted)
    obsession_targeted.blank? ? scoped : scoped.where(obsession: obsession_targeted)
  end
end
