class Treatment < ApplicationRecord
  has_many :user_treatments
  has_many :users, through: :user_treatments

  validates :type, presence: true
end
