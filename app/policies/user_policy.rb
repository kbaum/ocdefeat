class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? # admins can see every user on the index page
        scope.all
      elsif user.therapist? # therapists can only see patients on users index page
        scope.where(role: 1)
      elsif user.patient? # patients can only view therapists on users index page
        scope.where(role: 2)
      elsif user.unassigned?
        scope.none
      end
    end
  end

  def show?
    if user.admin? # admins can see every user's show page
      true
    elsif user.therapist? # therapists can see their own show page and all patients' show pages
      oneself || record.patient?
    elsif user.patient? # a patient can see his own show page and all therapists' show pages
      oneself || record.therapist?
    elsif user.unassigned? # an unassigned user can only see his own preliminary profile page
      oneself
    end
  end

  def edit?
    oneself
  end

  def permitted_attributes
    if oneself && record.unassigned? && record.provider == "twitter"
      [:name, :email, :password, :password_confirmation, :role_requested, :severity, :variant]
    elsif oneself
      [:name, :email, :password, :password_confirmation, :severity, :variant]
    elsif user.admin?
      [:role]
    end
  end

  def update?
    oneself || user.admin?
  end

  def destroy? # Only admins and the user who owns her account can delete her account
    if user.unassigned? || user.patient? || user.therapist?
      oneself
    elsif user.admin?
      true unless oneself # An admin cannot delete her own account
    end
  end

  private

    def oneself # the user logged in is the selfsame user (record) whose profile is being viewed
      user == record
    end
end
