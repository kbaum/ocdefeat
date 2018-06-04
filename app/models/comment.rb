class Comment < ApplicationRecord
  belongs_to :obsession
  belongs_to :user
  delegate :name, to: :user, prefix: true, allow_nil: true # calling #user_name on comment instance returns the name attribute value of the user instance to which the comment belongs.
end
