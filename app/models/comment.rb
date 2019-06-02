class Comment < ApplicationRecord
  extend Datable

  scope :advice, -> { where(user: User.therapists) }
  scope :concerns, -> { where(user: User.patients) }

  belongs_to :obsession
  belongs_to :user

  delegate :name, to: :user, prefix: "commenter", allow_nil: true # calling #commenter_name on comment instance returns the name attribute value of the user instance to which the comment belongs.

  validates :content, presence: true
end
