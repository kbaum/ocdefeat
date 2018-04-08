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
end
