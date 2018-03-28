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
  def self.find_or_create_by_omniauth(auth_hash)
    self.where(email: auth_hash["info"]["email"]).first_or_create do |user|
      user.name = auth_hash["info"]["name"]
      user.password = SecureRandom.hex
    end
  end
end

# Explanation of #find_or_create_by_omniauth(auth_hash):
# Trying to find user instance with the email provided by Facebook
# If a user exists in users DB table with that email, return that user instance
# If a user instance does NOT exist with that email, then create one with that Facebook email:
# The newly instantiated user instance that was just created is passed to the block,
# and we set its name attribute value = the name provided by Facebook -- auth_hash["info"]["name"]
# and we give it a random, unique string password using SecureRandom.hex
