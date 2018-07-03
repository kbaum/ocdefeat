class PatientFinder
  attr_accessor :initial_scope

  def initialize(initial_scope)
    @initial_scope = initial_scope
  end

  def filter_by_severity(scoped, severity)
    severity.blank? ? scoped : scoped.where("severity = ?", severity)
  end

  def filter_by_variant(scoped, variant)
    variant.blank? ? scoped : scoped.where("variant = ?", variant)
  end

  def filter_by_fixation(scoped, theme_id)
    if theme_id.blank?
      scoped
    else
      scoped.joins(obsessions: :theme).where(themes: { id: theme_id }).distinct
    end
  end

  def filter_by_treatment(scoped, treatment_id)
    if treatment_id.blank?
      scoped
    else
      scoped.joins(:treatments).where(treatments: { id: treatment_id }).distinct
    end
  end
end
