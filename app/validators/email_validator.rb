class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A[^@\s]+@[a-z\d\-.]+\.[a-z]{2,}\z/i

  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || 'is invalid') unless value =~ EMAIL_REGEX
  end
end
