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

  def show? # Admins and therapists can see every patient's plans. Patients can only see their own plans
    user.admin? || user.therapist? || plan_owner
  end

  def edit? # Only therapists and patient who developed plan can view form to edit plan title and goal
    user.therapist? || plan_owner
  end

  def update? # Only therapists and patient who developed plan can edit preliminary plan title and goal
    user.therapist? || plan_owner
  end

  def destroy? # Only patient who created ERP plan or therapist can delete it
    user.therapist? || plan_owner
  end

  private

    def plan_owner
      user == record.designer # instance method #designer called on plan instance (record) returns user who created plan
    end
end
