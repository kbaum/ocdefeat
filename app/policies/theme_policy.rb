class ThemePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.unassigned_user? || user.patient? || user.therapist? || user.admin?
        scope.all # all users can view the themes index page
      end
    end
  end

  def create? # Patients create new theme in the form to create new obsession; therapists create new theme on themes index page
    user.patient? || user.therapist?
  end

  def destroy? # only therapists can remove OCD themes (b/c they can judge whether a proposed OCD theme is an accurate type of OCD)
    user.therapist?
  end
end
