class CompletedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == true && !record.discomfort_degree.present?
      record.errors[attribute] << (options[:message] || "is a valid status only if you already rated your degree of discomfort when performing this step!")
    end
  end
end
