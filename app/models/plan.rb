class Plan < ApplicationRecord
  belongs_to :obsession
  has_many :steps
end
