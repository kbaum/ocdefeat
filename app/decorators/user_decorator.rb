class UserDecorator < ApplicationDecorator
  delegate_all

  def objects_count(string_object) # argument is a string like "obsession" or "plan"
    helpers.pluralize user.send("#{string_object}s").count, "#{string_object}"
  end
end
