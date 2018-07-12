class ApplicationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def created_on
    created_at.strftime("%A, %B %e, %Y, at %l:%M %p")
  end

  def last_modified
    updated_at.strftime("Last modified on %A, %B %e, %Y, at %l:%M %p")
  end

  def edit_link
    link_to polymorphic_path(object, action: "edit"), class: "btn btn-primary btn-sm" do
      content_tag(:span, nil, class: "glyphicon glyphicon-edit") + content_tag(:small, " Edit #{object.class}")
    end
  end

  def delete_link
    link_to polymorphic_path(object), method: :delete, data: { confirm: "Are you sure you want to delete this #{object.class.to_s.downcase}?" }, class: "btn btn-danger btn-sm" do
      content_tag(:span, nil, class: "glyphicon glyphicon-trash") + content_tag(:small, " Delete #{object.class}")
    end
  end
end
