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

  def self.all # calling #all on Filter class returns an array of all filter instances
    filterers = User.roles.keys.delete_if {|role| role == "unassigned"} #=> ["patient", "therapist", "admin"]
    filterers.map {|filterer| [Filter.new(filterer, "obsessions"), Filter.new(filterer, "plans"), Filter.new(filterer, "users")]}.flatten
  end
end

# Explanation of #to_partial_path called on filter instance:
# My index views of obsessions/ERP plans/users differ drastically depending on the viewer's role
# For example, when considering a users index,
# an admin views an index of ALL users - unassigned users, patients, therapists and admins alike,
# a therapist views a users index consisting ONLY of THEIR OWN patients,
# a patient views a users index consisting ONLY of therapists (i.e. a therapy directory)
# Because the content on these index view files would be drastically different,
# I decided to dynamically render different index view files depending on the viewer's role:
# #to_partial_path returns a string identifying the path associated with the object.
# ActionPack uses this to find a suitable partial to represent the object.
# For example, where theme is an instance of my Theme model,
# theme.to_partial_path returns "themes/theme"
# So I can override #to_partial_path method as it pertains to filter instances
# since I want to have different index pages (with different select_tag filters)
# dependending on the user viewing the page

# Explanation of class method #all called on Filter class:
# User.roles returns this hash: {"unassigned"=>0, "patient"=>1, "therapist"=>2, "admin"=>3}
# User.roles.keys returns this array: ["unassigned", "patient", "therapist", "admin"]
# User.roles.keys.delete_if {|role| role == "unassigned"} returns ["patient", "therapist", "admin"]
# We are calling #map on filterers array: ["patient", "therapist", "admin"]
# #map returns an array of values resulting from invoking the block once on each array element, so
# for each string element in filterers array, we are creating an ARRAY consisting of THREE filter instances:
# and EACH filter instance has a filterer attribute = to that string element and a second argument
# of "obsessions", "plans", or "users", i.e., the type of object being filtered
# Example of invoking the block for 1 string element in filterers array:
# [Filter.new("patient", "obsessions"), Filter.new("patient", "plans"), Filter.new("patient", "users")]
# Then calling #flatten on the array of arrays smushes the arrays together into 1 array
# Calling Filter.all returns this array:
# [
# <Filter:0x007f93ed031ac8 @filterer="patient", @filtered="obsessions">,
# <Filter:0x007f93ed0318e8 @filterer="patient", @filtered="plans">,
# <Filter:0x007f93ed0317f8 @filterer="patient", @filtered="users">,
# <Filter:0x007f93ed031640 @filterer="therapist", @filtered="obsessions">,
# <Filter:0x007f93ed031398 @filterer="therapist", @filtered="plans">,
# <Filter:0x007f93ed031028 @filterer="therapist", @filtered="users">,
# <Filter:0x007f93ed030e70 @filterer="admin", @filtered="obsessions">,
# <Filter:0x007f93ed030e20 @filterer="admin", @filtered="plans">,
# <Filter:0x007f93ed030d30 @filterer="admin", @filtered="users">
# ]
