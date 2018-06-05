class Comment < ApplicationRecord
  scope :counseling_comments, -> { where(user_id: User.therapists) }
  belongs_to :obsession
  belongs_to :user
  delegate :name, to: :user, prefix: true, allow_nil: true # calling #user_name on comment instance returns the name attribute value of the user instance to which the comment belongs.
  validates :content, presence: true
end
