class ThemePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.unassigned? || user.patient? || user.therapist? || user.admin?
        scope.all # all users can view the themes index page
      end
    end
  end

  def create?
    user.therapist?
  end

  def destroy?
    user.therapist?
  end
end
