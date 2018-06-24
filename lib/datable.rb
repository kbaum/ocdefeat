module Datable
  def from_today
    where("created_at >=?", Time.zone.today.beginning_of_day)
  end

  def before_today
    where("created_at <?", Time.zone.today.beginning_of_day)
  end

  def most_recently_updated
    order(updated_at: :desc).first
  end
end
