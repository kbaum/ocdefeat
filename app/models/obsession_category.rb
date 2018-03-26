class ObsessionCategory < ApplicationRecord
  belongs_to :obsession
  belongs_to :category
end
