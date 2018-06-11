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

  def destroy? # only therapists can remove OCD themes (b/c they can judge whether a proposed OCD theme is an accurate type of OCD)
    user.therapist?
  end
end
