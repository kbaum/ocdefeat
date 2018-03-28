class User < ApplicationRecord
  enum role: { unassigned_user: 0, patient: 1, therapist: 2, admin: 3 }
  #enum role: { "unassigned_user" => 0, "patient" => 1, "therapist" => 2, "admin" => 3 }
  has_many :obsessions, dependent: :destroy
  has_many :plans, through: :obsessions, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, email: true, uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 8 }, allow_nil: true
  # when a user edits their user information, they don't have to retype their password
end
