class ThemePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.unassigned_user? || user.patient? || user.therapist? || user.admin?
        scope.all # all users can view the themes index page
      end
    end
  end

  def create? # only patients can create a new OCD theme (in the form to create a new obsession)
    user.patient?
  end

  def destroy? # only therapists can remove OCD themes (b/c they can judge whether a proposed OCD theme is an accurate type of OCD)
    user.therapist?
  end
end
