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

  def show?
    if user.patient? # A patient can only see her own obsessions' show pages
      obsession_owner
    elsif user.therapist? # A therapist can only see obsessions that belong to her own patients
      record.user.in?(user.counselees)
    end
  end

  def edit?
    obsession_owner
  end

  def update?
    obsession_owner
  end

  def destroy?
    obsession_owner
  end

  private

    def obsession_owner
      user == record.user # record refers to the obsession instance
    end
end
