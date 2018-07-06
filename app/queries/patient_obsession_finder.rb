class PatientObsessionFinder
  attr_accessor :default_scope

  def initialize(default_scope) # default scope is AR::Relation of the patient's own obsessions
    @default_scope = default_scope
  end

  def call(params)
    scoped = search_thoughts(default_scope, params[:search_thoughts])
    scoped = filter_by_min_anxiety_rating(scoped, params[:min_anxiety_rating])
    scoped = filter_by_max_anxiety_rating(scoped, params[:max_anxiety_rating])
    scoped
  end

  def search_thoughts(scoped, keywords)
    keywords.blank? ? scoped : scoped.where("intrusive_thought LIKE ?", "%#{keywords}%")
  end

  def filter_by_min_anxiety_rating(scoped, min_anxiety_rating)
    min_anxiety_rating.blank? ? scoped : scoped.where("anxiety_rating >= ?", min_anxiety_rating)
  end

  def filter_by_max_anxiety_rating(scoped, max_anxiety_rating)
    max_anxiety_rating.blank? ? scoped : scoped.where("anxiety_rating <= ?", max_anxiety_rating)
  end
end
