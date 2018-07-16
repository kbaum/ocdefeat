class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? # admins can see every user on the index page
        scope.all
      elsif user.therapist? # therapists can only see their own patients on users index page
        scope.where(id: user.counselees)
      elsif user.patient? # patients can only view therapists on users index page (therapist directory)
        scope.where(role: 2)
      elsif user.unassigned?
        scope.none
      end
    end
  end

  def new?
    true unless user
  end

  def show?
    if user.admin? # An admin can see every user show page
      true
    elsif user.therapist? # A therapist can see her own show page and her own patients' show pages
      oneself || record.counselor == user
    elsif user.patient? # A patient can see her own show page and all therapists' show pages
      oneself || record.therapist?
    elsif user.unassigned? # An unassigned user can only see her own preliminary profile page
      oneself
    end
  end

  def edit?
    oneself
  end

  def permitted_attributes
    if oneself && record.unassigned?
      [:name, :email, :password, :password_confirmation, :role_requested, :severity, :variant]
    elsif oneself
      [:name, :email, :password, :password_confirmation, :severity, :variant]
    elsif user.admin?
      [:role, :counselor_id]
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

  def show_comments?
    record.counselor == user || oneself
  end

  private

    def oneself # the user logged in is the selfsame user (record) whose profile is being viewed
      user == record
    end
end
