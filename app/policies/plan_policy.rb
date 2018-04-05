class PlanPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.therapist? || user.admin? # Therapists and admins can see the index of all ERP plans
        scope.all
      elsif user.patient? # A patient can only view an index of HIS OWN plans
        scope.where("obsession_id IN (?)", user.obsession_ids)
      end
    end
    # a plan belongs to an obsession, so a plan instance has obsession_id foreign key.
    # a user has many obsessions, so user.obsession_ids returns array of IDs of obsessions belonging to that user
  end

  def new? # Only patients can view the form to create an ERP plan
    user.patient?
  end

  def create? # Only patients can create a preliminary plan, including title and goal
    user.patient?
  end
end
