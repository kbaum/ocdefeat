class PatientFinder
  attr_accessor :default_scope

  def initialize(default_scope)
    @default_scope = default_scope
  end

  def call(params)
    scoped = filter_by_severity(default_scope, params[:severity])
    scoped = filter_by_variant(scoped, params[:variant])
    scoped = filter_by_fixation(scoped, params[:theme_fixation])
    scoped = filter_by_treatment(scoped, params[:treatment_undergone])
    scoped = filter_by_rumination_recency(scoped, params[:recent_ruminators])
    scoped
  end

  def filter_by_severity(scoped, severity)
    severity.blank? ? scoped : scoped.where("severity = ?", severity)
  end

  def filter_by_variant(scoped, variant)
    variant.blank? ? scoped : scoped.where("variant = ?", variant)
  end

  def filter_by_fixation(scoped, theme_fixation)
    if theme_fixation.blank?
      scoped
    else
      scoped.joins(obsessions: :theme).where(themes: { id: theme_fixation }).distinct
    end
  end

  def filter_by_treatment(scoped, treatment_undergone)
    if treatment_undergone.blank?
      scoped
    else
      scoped.joins(:treatments).where(treatments: { id: treatment_undergone }).distinct
    end
  end

  def filter_by_rumination_recency(scoped, recent_ruminators)
    if recent_ruminators.blank?
      scoped
    else
      if recent_ruminators == "Patients who reported new obsessions yesterday"
        interval = (Time.now.midnight - 1.day)..Time.now.midnight
      elsif recent_ruminators == "Patients who reported new obsessions today"
        interval = Time.now.midnight..Time.now
      end
      scoped.patients_obsessing.where(obsessions: { created_at: interval })
    end
  end
end
