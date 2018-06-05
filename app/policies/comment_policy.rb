class CommentPolicy < ApplicationPolicy
  def create?
    user.patient? || user.therapist?
  end

  def update?
    comment_owner
  end

  def destroy?
    patient_obsessing || comment_owner
  end

  private

    def patient_obsessing
      record.obsession.user == user
    end

    def comment_owner
      record.user == user
    end
end
