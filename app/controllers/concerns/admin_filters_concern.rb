module AdminFiltersConcern
  extend ActiveSupport::Concern

  included do
    helper_method :filter_by_date
  end

  def filter_by_date
    scoped_objects = policy_scope(controller_name.classify.constantize)
    verb = scoped_objects.first.class == Obsession ? "reported" : "designed"

    if current_user.admin?
      if !params[:date].blank? # Admin filters obsessions/plans by date created
        if params[:date] == "Today"
          if scoped_objects.from_today.empty? # If no obsessions/plans were created today
            flash.now[:alert] = "No new #{controller_name} were #{verb} today."
          else
            objects = scoped_objects.from_today # stores AR::Relation of all obsessions/plans created today
            flash.now[:notice] = "You found #{objects.count} #{objects.first.class.to_s.downcase.pluralize(objects.count)} #{verb} today!"
          end
        elsif params[:date] == "Before Today"
          if scoped_objects.before_today.empty? # If no obsessions/plans were created prior to today
            flash.now[:alert] = "No #{controller_name} were #{verb} before today."
          else
            objects = scoped_objects.before_today # stores AR::Relation of all obsessions/plans created prior to today
            flash.now[:notice] = "You found #{objects.count} #{objects.first.class.to_s.downcase.pluralize(objects.count)} #{verb} before today!"
          end
        end
      else # Admin did not choose a filter
        objects = scoped_objects # stores AR::Relation of all patients' obsessions/plans
        message =
          if objects.first.class == Obsession
            "OCD spikes are sparsely detailed and displayed anonymously to preserve patient privacy."
          else
            "Basic information about each ERP plan is displayed below."
          end
        flash.now[:notice] = "#{message}"
      end
      objects
    end
  end
end
# controller_name returns "obsessions" or "plans"
# controller_name.classify returns "Obsession" or "Plan"
# controller_name.classify.constantize returns
