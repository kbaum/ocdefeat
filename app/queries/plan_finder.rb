class PlanFinder
  attr_accessor :default_scope

  def initialize(default_scope) # the patient's own plans or the therapist's patients' plans
    @default_scope = default_scope
  end
end
