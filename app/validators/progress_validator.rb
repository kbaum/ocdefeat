class ProgressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == 1 && record.steps.empty?
      record.errors[attribute] << (options[:message] || "cannot be made unless you add exposure exercises to your preliminary ERP plan!")
    elsif value == 1 && !record.steps.all? {|step| step.complete?}
      record.errors[attribute] << (options[:message] || "and full accomplishment of this ERP plan can only be achieved if each step comprising the plan is marked as complete!")
    end
  end
end

# An accomplished plan must have at least 1 step and all steps must be marked as complete
