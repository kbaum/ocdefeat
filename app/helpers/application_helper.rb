module ApplicationHelper

  def set_class_for(flash_type)
    case flash_type
    when "error"
      "alert-danger"    # Red
    when "alert"
      "alert-warning"   # Yellow
    when "notice"
      "alert-info"      # Blue
    end
  end

  def created_on(instance)
    instance.created_at.strftime("%A, %B %e, %Y, at %l:%M %p")
  end

end
