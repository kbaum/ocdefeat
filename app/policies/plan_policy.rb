class PlanPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? # An admin views an index of all plan titles
        scope.all
      elsif user.therapist? # A therapist views an index of her own patients' plans
        scope.where(obsession: user.counselees.map {|counselee| counselee.obsessions}.flatten)
      elsif user.patient? # A patient views an index of her own plans
        scope.where(obsession_id: user.obsession_ids)
      end
    end
  end

  def new? # Only patients can view the form to create an ERP plan
    user.patient?
  end

  def create? # Only patients can create an ERP plan overview (title, goal, obsession_id, flooded, progress)
    user.patient?
  end

  def show?
    if user.therapist? # A therapist views the show pages of plans designed by her own patients
      record.obsession.in?(user.counselees.map {|counselee| counselee.obsessions}.flatten)
    elsif user.patient? # A patient sees her own plans
      plan_owner
    end
  end

  def edit?
    user.therapist? || plan_owner
  end

  def permitted_attributes # once the plan's :obsession_id was assigned in plans#create, it cannot be changed
    if user.therapist?
      [:title, :goal, :flooded]
    elsif plan_owner
      [:title, :goal, :flooded, :progress]
    end
  end

  def update?
    user.therapist? || plan_owner
  end

  def destroy? # Only patient who created ERP plan or therapist can delete it
    user.therapist? || plan_owner
  end

  private

    def plan_owner
      user == record.user
    end

    def plans_by_patient_caseload
      if user.therapist?
        record.obsession.in?(user.counselees.map {|counselee| counselee.obsessions}.flatten)
      end
    end
end
