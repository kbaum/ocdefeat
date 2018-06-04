class Note < ApplicationRecord
  belongs_to :user
  delegate :name, to: :user, prefix: true, allow_nil: true # calling #user_name on note instance returns the name attribute value of the user instance to which the note belongs.
  validates :content, presence: true
end
