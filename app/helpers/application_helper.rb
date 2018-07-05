module ApplicationHelper

  def validation_errors_for(object = nil) # object is an AR instance or nil by default
    if object && object.errors.any?
      render partial: "shared/error_explanation_div", locals: { object: object }
    end
  end

  def set_class_for(flash_type)
    case flash_type
    when "error"
      "alert-danger"    # Red
    when "alert"
      "alert-warning"   # Yellow
    when "notice"
      "alert-info"      # Blue
    when "success"
      "alert-success"   # Green
    end
  end

  def created_on(instance)
    instance.created_at.strftime("%A, %B %e, %Y, at %l:%M %p")
  end

  def updated_on(instance)
    instance.updated_at.strftime("%A, %B %e, %Y, at %l:%M %p")
  end
end
