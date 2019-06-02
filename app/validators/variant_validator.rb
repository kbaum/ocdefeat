class VariantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == "Neither"
      record.errors[:variant] << (options[:message] || "is not a valid variant of OCD for a patient") if record.role_requested == "Patient"
    else
      record.errors[:variant] << (options[:message] || "is not a valid variant of OCD for an admin or therapist") if (record.role_requested == "Therapist" || record.role_requested == "Admin")
    end
  end
end
