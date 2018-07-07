module AdminFiltersConcern
  extend ActiveSupport::Concern

  included do
    helper_method :filter_by_date
  end

  def filter_by_date
    scoped_objects = policy_scope(controller_name.classify.constantize)

    if current_user.admin?
      if !params[:date].blank? # Admin filters obsessions/plans by date created
        if params[:date] == "Today"
          if scoped_objects.from_today.empty? # If no obsessions/plans were created today
            flash.now[:alert] = "No new #{controller_name} were reported today."
          else
            objects = scoped_objects.from_today # stores AR::Relation of all obsessions/plans created today
            flash.now[:success] = "You found #{plural_inflection(objects)} reported today!"
          end
        elsif params[:date] == "Old Obsessions"
          if scoped_objects.before_today.empty? # If no obsessions/plans were created prior to today
            flash.now[:alert] = "No #{controller_name} were created before today."
          else
            objects = scoped_objects.before_today # stores AR::Relation of all obsessions/plans created prior to today
            flash.now[:success] = "You found #{objects.count} #{objects.first.class.to_s.downcase.pluralize(objects.count)} reported before today!"
          end
        end
      else # Admin did not choose a filter
        objects = scoped_objects # stores AR::Relation of all patients' obsessions/plans
        if objects.first.class == Obsession
          message = "OCD spikes are sparsely detailed and displayed anonymously to preserve patient privacy."
        elsif objects.first.class == Plan
          message = "ERP plans are only listed by title to preserve doctor-patient confidentiality."
        end
        flash.now[:success] = "#{message}"
      end
      objects
    end
  end
end
