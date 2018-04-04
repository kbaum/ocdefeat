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

  def create? # only patients can create obsessions
    user.patient?
  end

  def show? # Admins and therapists can view all obsession show pages, but a patient can only view his own obsessions' show pages
    user.admin? || user.therapist? || obsession_owner
  end

  private

    def obsession_owner
      user == record.user # record refers to the obsession instance
    end
end
