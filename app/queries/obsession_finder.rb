class ObsessionFinder
  attr_accessor :default_scope

  def initialize(default_scope) # the patient's own obsessions or the therapist's patients' obsessions
    @default_scope = default_scope
  end

  def call(params)
    scoped = search_thoughts(default_scope, params[:search_thoughts])
    scoped = filter_by_min_time_consumed(scoped, params[:min_time_consumed])
    scoped = filter_by_max_time_consumed(scoped, params[:max_time_consumed])
    scoped = filter_by_erp_approach(scoped, params[:approach])
    scoped = filter_by_min_anxiety_rating(scoped, params[:min_anxiety_rating])
    scoped = filter_by_max_anxiety_rating(scoped, params[:max_anxiety_rating])
    scoped = filter_by_ocd_theme(scoped, params[:ocd_theme])
    scoped
  end

  def search_thoughts(scoped, keywords)
    keywords.blank? ? scoped : scoped.where("intrusive_thought LIKE ?", "%#{keywords}%")
  end

  def filter_by_min_time_consumed(scoped, min_time_consumed)
    min_time_consumed.blank? ? scoped : scoped.where("time_consumed >= ?", min_time_consumed)
  end

  def filter_by_max_time_consumed(scoped, max_time_consumed)
    max_time_consumed.blank? ? scoped : scoped.where("time_consumed <= ?", max_time_consumed)
  end

  def filter_by_erp_approach(scoped, strategy)
    if strategy.blank?
      scoped
    else
      if strategy == "Flooding"
        scoped.defeatable_by_flooding
      else
        scoped.defeatable_by_graded_exposure
      end
    end
  end

  def filter_by_min_anxiety_rating(scoped, min_anxiety_rating)
    min_anxiety_rating.blank? ? scoped : scoped.where("anxiety_rating >= ?", min_anxiety_rating)
  end

  def filter_by_max_anxiety_rating(scoped, max_anxiety_rating)
    max_anxiety_rating.blank? ? scoped : scoped.where("anxiety_rating <= ?", max_anxiety_rating)
  end

  def filter_by_ocd_theme(scoped, theme)
    theme.blank? ? scoped : scoped.where(theme: theme)
  end
end
