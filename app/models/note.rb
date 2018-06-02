class Note < ApplicationRecord
  belongs_to :user
  delegate :name, to: :user, prefix: :therapist # I can call #therapist_name on note instance to return the name attribute value of the user instance to which the note belongs.
end
