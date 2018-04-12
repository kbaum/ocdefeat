class Filter # Filter is NOT an ActiveRecord model b/c there is no DB table
  attr_reader :filterer # string role of viewer (person filtering): "patient", "therapist" or "admin"
  attr_reader :filtered # string name of objects being filtered: "obsessions", "plans" or "users"

  def initialize(filterer, filtered) # a filter instance is instantiated with 2 string attributes
    @filterer = filterer
    @filtered = filtered
  end

  def to_partial_path # returns the string name of the partial that will be rendered
    "filter_#{filtered}/#{filterer}"
  end
end

# Explanation of #to_partial_path called on filter instance:
# My index views of obsessions/ERP plans/users differ drastically depending on the viewer's role
# For example, when considering a users index,
# an admin views an index of ALL users - unassigned_users, patients, therapists and admins alike,
# a therapist views a users index consisting ONLY of patients,
# a patient views a users index consisting ONLY of therapists (i.e. a therapy directory)
# Because the content on these index view files would be drastically different,
# I decided to dynamically render different index view files depending on the viewer's role:
# #to_partial_path returns a string identifying the path associated with the object.
# ActionPack uses this to find a suitable partial to represent the object.
# For example, where theme is an instance of my Theme model,
# theme.to_partial_path returns "themes/theme"
# So I can override #to_partial_path method
# since I want to have different index pages (with different filters)
# dependending on the user viewing the page
