class ThemePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.unassigned? || user.patient? || user.therapist? || user.admin?
        scope.all # all users can view the themes index page
      end
    end
  end

  def new?
    user.therapist?
  end

  def create?
    new?
  end

  def destroy?
    new?
  end
end
