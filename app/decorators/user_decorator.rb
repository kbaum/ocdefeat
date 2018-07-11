class UserDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all

  def objects_count(object_type) # argument is a string like "obsession" or "plan"
    pluralize user.send("#{object_type}s").count, object_type
  end

  def pronouns_for_defeating_ocd
    current_user.patient? ? "You are currently defeating" : "The patient is currently defeating"
  end

  def pronouns_for_designing_plans
    current_user.patient? ? "You designed" : "The patient designed"
  end

  def present_clinical_presentation
    user.in?(User.symptomatic) ? "Symptomatic" : "Asymptomatic"
  end

  def demand_data(attribute_name) # argument is the string "severity" or "variant"
    if current_user.patient?
      content_tag(:div, class: "alert alert-warning", role: "alert") do
        content_tag(:label, "Please indicate your OCD #{attribute_name} in") +
        link_to(" your account information", edit_user_path(current_user), class: "alert-link") + "."
      end
    else
      content_tag(:div, class: "alert alert-info", role: "alert") do
        content_tag(:label, "#{attribute_name.capitalize}") + ":" + " The patient has been instructed to comply by entering appropriate information."
      end
    end
  end

  def show_severity
    if severity.in?(%w(Mild Moderate Severe Extreme))
      content_tag(:h4, "#{name} vs. #{severity} OCD")
    else
      demand_data("severity")
    end
  end

  def vary_variant
    if variant.in?(["Traditional", "Purely Obsessional", "Both"])
      content_tag(:label, "OCD Variant") + ":" +
      case variant
      when "Traditional"
        " Traditional"
      when "Purely Obsessional"
        " Pure-O"
      when "Both"
        " Hybrid of Traditional and Pure-O"
      end
    else
      demand_data("variant")
    end
  end
end
