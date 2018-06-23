class CommentPolicy < ApplicationPolicy
  def create?
    user.patient? || user.therapist?
  end

  def edit?
    comment_owner
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
end

# A patient can only comment on her own obsessions (a patient can only see her own obsessions' show pages)
# A therapist can only comment on her own patients' obsessions (a therapist can only see her own patients' obsessions' show pages)
