class FinishedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == true && record.without_step_or_with_incomplete_step?
      record.errors[attribute] << (options[:message] || "is not a valid status for a plan that has no steps or incomplete steps!")
    end
  end
end
