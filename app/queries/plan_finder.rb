class PlanFinder
  attr_accessor :default_scope

  def initialize(default_scope) # the patient's own plans or the therapist's patients' plans
    @default_scope = default_scope
  end

  def call(params)
    scoped = search_titles(default_scope, params[:title_terms])
    scoped = filter_by_obsession_targeted(scoped, params[:obsession_targeted])
    scoped
  end

  def search_titles(scoped, title_terms)
    title_terms.blank? ? scoped : scoped.where("title LIKE ?", "%#{title_terms}%")
  end

  def filter_by_obsession_targeted(scoped, obsession_targeted)
    obsession_targeted.blank? ? scoped : scoped.where(obsession: obsession_targeted)
  end

  def filter_by_accomplishment(scoped, accomplishment)
    if accomplishment.blank?
      scoped
    else
      if accomplishment == "Accomplished Plans"
        scoped.where(finished: true)
      else
        scoped.where.not(finished: true)
      end
    end
  end
end
