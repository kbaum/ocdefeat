class PlanFinder
  attr_accessor :default_scope

  def initialize(default_scope) # the patient's own plans or the therapist's patients' plans
    @default_scope = default_scope
  end

  def call(params)
    scoped = search_titles(default_scope, params[:title_terms])
    scoped = filter_by_obsession_targeted(scoped, params[:obsession_targeted])
    scoped = filter_by_accomplishment(scoped, params[:accomplishment])
    scoped = filter_by_delineation(scoped, params[:delineation])
    scoped = filter_by_approach(scoped, params[:approach])
    scoped = filter_by_theme(scoped, params[:ocd_theme])
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
      accomplishment == "Accomplished Plans" ? scoped.accomplished : scoped.unaccomplished
    end
  end

  def filter_by_delineation(scoped, delineation)
    if delineation.blank?
      scoped
    else
      delineation == "Plans with Steps" ? scoped.with_steps : scoped.stepless
    end
  end

  def filter_by_approach(scoped, approach)
    if approach.blank?
      scoped
    else
      approach == "Flooding" ? scoped.flooding : scoped.graded_exposure
    end
  end

  def filter_by_theme(scoped, theme)
    theme.blank? ? scoped : scoped.by_theme(theme)
  end
end
