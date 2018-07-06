class PatientObsessionFinder
  attr_accessor :default_scope

  def initialize(default_scope) # default scope is AR::Relation of the patient's own obsessions
    @default_scope = default_scope
  end

  def call(params)
    scoped = search_thoughts(default_scope, params[:search_thoughts])
  end

  def search_thoughts(scoped, keywords)
    keywords.blank? ? scoped : scoped.where("intrusive_thought LIKE ?", "%#{keywords}%")
  end
end
