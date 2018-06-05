class CommentPolicy < ApplicationPolicy
  def create?
    user.patient? || user.therapist?
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
