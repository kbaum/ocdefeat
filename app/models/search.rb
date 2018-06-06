class Search < ApplicationRecord
  def obsessions
    @obsessions ||= obtain_obsessions
  end

  private

    def obtain_obsessions
      obsessions = Obsession.order(:intrusive_thought)
      obsessions = obsessions.where("intrusive_thought like ?", "%#{key_terms}%") if key_terms.present?
      obsessions = obsessions.where(theme_id: theme_id) if theme_id.present?
      obsessions = obsessions.where("anxiety_rating >= ?", min_anxiety_rating) if min_anxiety_rating.present?
      obsessions = obsessions.where("anxiety_rating <= ?", max_anxiety_rating) if max_anxiety_rating.present?
      obsessions
    end
end
