module AdminFiltersConcern
  extend ActiveSupport::Concern

  included do
    helper_method :filter_by_date
  end
end
