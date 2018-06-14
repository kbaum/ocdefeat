class StepPolicy < ApplicationPolicy # A step does not exist outside the context of an ERP plan
  def create? # patient who owns plan to which the step belongs, and any therapist, can create a new step for that plan
    user.patient? || user.therapist?
  end

  def permitted_attributes # once the step's :plan_id was assigned in steps#create, it cannot be changed
    if user.therapist? || plan_possessor
      [:instructions, :duration, :discomfort_degree, :status]
    end
  end

  def update? # Therapists and the patient who created the plan to which the step belongs can edit the step
    plan_possessor || user.therapist?
  end

  def destroy? # Therapists and the patient who created the plan to which the step belongs can delete the step
    plan_possessor || user.therapist?
  end

  private

  def plan_possessor
    user == record.plan.user
  end
end
