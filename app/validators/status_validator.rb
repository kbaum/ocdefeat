class StatusValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == 1 && !record.discomfort_degree.present?
      record.errors[attribute] << (options[:message] || "cannot be marked as complete if you haven't rated your degree of discomfort yet!")
    end
  end
end
