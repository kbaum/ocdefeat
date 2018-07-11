class UserDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all

  def objects_count(string_object) # argument is a string like "obsession" or "plan"
    pluralize user.send("#{string_object}s").count, "#{string_object}"
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
end
