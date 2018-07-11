class UserDecorator < ApplicationDecorator
  delegate_all

  def objects_count(string_object) # argument is a string like "obsession" or "plan"
    helpers.pluralize user.send("#{string_object}s").count, "#{string_object}"
  end

  def pronouns_for_conquering_ocd
    current_user.patient? ? "You are currently conquering" : "The patient is currently conquering"
  end

  def pronouns_for_planning
    current_user.patient? ? "You designed" : "The patient designed"
  end
end
