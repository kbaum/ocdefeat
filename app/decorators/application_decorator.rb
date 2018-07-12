class ApplicationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def created_on
    created_at.strftime("%A, %B %e, %Y, at %l:%M %p")
  end

  def last_modified
    updated_at.strftime("Last modified on %A, %B %e, %Y, at %l:%M %p")
  end

  def object_type
    case object.class.to_s
    when "User"
      "Account"
    when "Plan"
      "Plan Overview"
    else
      object.class.to_s
    end
  end

  def edit_link
    link_to polymorphic_path(object, action: "edit"), class: "btn btn-primary btn-sm" do
      content_tag(:span, nil, class: "glyphicon glyphicon-edit") + content_tag(:small, " Edit #{object_type}")
    end
  end
end
