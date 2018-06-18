class ProgressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || "toward achieving your goals depends on the creation and completion of exposure exercises!")
  end
end
