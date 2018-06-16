class ProgressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == 1 && record.steps.empty?
      record.errors[attribute] << (options[:message] || "cannot be made unless you add exposure exercises to your ERP plan!")
    elsif value == 1 && !record.steps.all? {|step| step.complete?}
      record.errors[attribute] << (options[:message] || "toward completion of this ERP plan can only be achieved if each step comprising the plan is marked complete!")
    end
  end
end

# Explanation:
# If the user checks the progress checkbox (on the plan show page) to indicate that the plan is finished,
# (trying to set the plan's progress attribute value = 1),
# but the plan does NOT contain any steps at all,
# the user will be UNABLE to update the plan as finished
# and will instead receive the error message:
# "Progress cannot be made unless you add exposure exercises to your ERP plan!"

# If the user checks the progress checkbox (on the plan show page) to indicate that the plan is finished,
# (trying to set the plan's progress attribute value = 1)
# but all of the plan's steps have NOT been marked as complete (a step is complete if its status = 1),
# the user will be UNABLE to update the plan as finished
# and will instead receive the error message:
# Progress toward completion of this ERP plan can only be achieved if each step comprising the plan is marked complete!

# Therefore, a plan can only be marked as finished
# (i.e. have its progress attribute value set = 1 and plan.finished? returns true)
# if the plan contains at least 1 step and all steps belonging to the plan are marked as complete
