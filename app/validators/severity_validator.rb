class SeverityValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == "Nonobsessive"
      record.errors[:severity] << (options[:message] || "is not a valid OCD severity for a patient") if record.role_requested == "Patient"
    else
      record.errors[:severity] << (options[:message] || "is not a valid OCD severity for an admin or therapist") if (record.role_requested == "Therapist" || record.role_requested == "Admin")
    end
  end
end
