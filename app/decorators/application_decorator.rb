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
    object.class.to_s == "User" ? "Account" : object.class.to_s
  end

  def edit_link
    link_to polymorphic_path(object, action: "edit"), class: "btn btn-primary btn-sm" do
      content_tag(:span, nil, class: "glyphicon glyphicon-edit") + content_tag(:small, " Edit #{object_type}")
    end
  end

  def delete_confirmation
    fragment =
      case object.class.to_s
      when "User"
        "permanently leave the OCDefeat community?"
      when "Obsession"
        "delete this obsession from your patient history?"
      when "Plan"
        "delete this ERP plan?"
      when "Step"
        "delete this exposure exercise?"
      when "Theme"
        "delete this OCD theme?"
      when "Comment"
        "delete this comment?"
      end
    "Do you want to " << fragment
  end

  def delete_link
    link_to polymorphic_path(object), method: :delete, data: { confirm: delete_confirmation }, class: "btn btn-danger btn-sm" do
      content_tag(:span, nil, class: "glyphicon glyphicon-trash") + content_tag(:small, " Delete #{object_type}")
    end
  end
end
