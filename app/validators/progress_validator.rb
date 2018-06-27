class ProgressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == 1 && record.without_step_or_with_incomplete_step?
      record.errors[attribute] << (options[:message] || "toward achieving your goals depends on the creation and completion of exposure exercises!")
    end
  end
end
