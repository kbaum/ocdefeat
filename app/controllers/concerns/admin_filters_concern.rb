module AdminFiltersConcern
  extend ActiveSupport::Concern

  included do
    helper_method :filter_by_date
  end

  def filter_by_date
    scoped_objects = policy_scope(controller_name.classify.constantize)
  end
end
