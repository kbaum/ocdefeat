class CommentPolicy < ApplicationPolicy
  def create?
    patient_comments_on_own_obsession || therapist_comments_on_counselees_obsessions
  end

  def edit?
    comment_owner
  end

  def permitted_attributes
    if comment_owner
      [:content] # user_id and #obsession_id cannot be changed once set in #create
    end
  end

  def update?
    comment_owner
  end

  def destroy?
    comment_owner
  end

  private

    def comment_owner
      record.user == user
    end

    def patient_comments_on_own_obsession
      user.patient? && record.obsession.in?(user.obsessions)
    end

    def therapist_comments_on_counselees_obsessions
      user.therapist? && record.obsession.in?(user.counselees.map {|counselee| counselee.obsessions}.flatten)
    end
end

# A patient can only comment on her own obsessions (a patient can only see her own obsessions' show pages)
# A therapist can only comment on her own patients' obsessions (a therapist can only see her own patients' obsessions' show pages)
