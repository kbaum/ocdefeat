class Tip < ApplicationRecord
  belongs_to :user
  delegate :name, to: :user, prefix: :therapist # I can call #therapist_name on tip instance to return the name attribute value of user instance to which tip belongs.
end
