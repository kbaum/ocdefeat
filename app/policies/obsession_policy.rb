class ObsessionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.therapist? # An admin or therapist can view the index of all obsessions
        scope.all
      elsif user.patient? # For confidentiality purposes, a patient can only view their own obsessions
        scope.where(user: user)
      end
    end
  end

  def new? # only patients can view the form to create a new obsession
    user.patient?
  end
end
