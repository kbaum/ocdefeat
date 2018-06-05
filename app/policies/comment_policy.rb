class CommentPolicy < ApplicationPolicy
  def create?
    patient_obsessing || user.therapist?
  end

  private

    def patient_obsessing
      record.obsession.user == user
    end
end
