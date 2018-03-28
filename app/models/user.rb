class User < ApplicationRecord
  enum role: { unassigned_user: 0, patient: 1, therapist: 2, admin: 3 }
  #enum role: { "unassigned_user" => 0, "patient" => 1, "therapist" => 2, "admin" => 3 }
  has_secure_password
  has_many :obsessions, dependent: :destroy
  has_many :plans, through: :obsessions, dependent: :destroy
end
