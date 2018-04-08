class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? # admins can see every user on the index page
        scope.all
      elsif user.therapist? # therapists can only see patients on users index page
        scope.where(role: 1)
      elsif user.patient? # patients can only view therapists on users index page
        scope.where(role: 2)
      elsif user.unassigned_user?
        scope.none
      end
    end
  end

  def show?
    if user.admin? # admins can see every user's show page
      true
    elsif user.therapist? # therapists can see their own show page and all patients' show pages
      oneself || record.patient?
    elsif user.patient? || user.unassigned_user? # a patient can only see his own show page
      oneself # and an unassigned user can only see his own preliminary profile page
    end
  end

  private

    def oneself # the user logged in is the selfsame user (record) whose profile is being viewed
      user == record
    end
end
