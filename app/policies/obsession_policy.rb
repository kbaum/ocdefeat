class ObsessionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? # An admin can view the index of all obsessions (thought is displayed anonymously)
        scope.all
      elsif user.therapist? # A therapist can view the index of her own counselees' obsessions
        scope.where(user: user.counselees)
      elsif user.patient? # For confidentiality purposes, a patient can only view her own obsessions
        scope.where(user: user)
      end
    end
  end

  def new? # only patients can view the form to create a new obsession
    user.patient?
  end

  def create? # only patients can create obsessions
    new?
  end

  def show?
    if user.patient? # A patient can only see her own obsessions' show pages
      obsession_owner
    elsif user.therapist? # A therapist can only see her own counselees' obsession show pages
      record.user.in?(user.counselees)
    end
  end

  def edit?
    obsession_owner
  end

  def permitted_attributes # user_id cannot be changed
    if obsession_owner
      [:intrusive_thought, :triggers, :anxiety_rating, :symptoms, :rituals, :time_consumed, :theme_id]
    end
  end

  def update?
    edit?
  end

  def destroy?
    obsession_owner
  end

  private

    def obsession_owner
      user == record.user
    end
end
