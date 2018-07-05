class PatientObsessionFinder
  attr_accessor :default_scope

  def initialize(default_scope) # default scope is AR::Relation of the patient's own obsessions
    @default_scope = default_scope
  end
end
