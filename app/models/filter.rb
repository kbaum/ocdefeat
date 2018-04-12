class Filter # Filter is NOT an ActiveRecord model b/c there is no DB table
  attr_reader :filterer # string role of viewer (person filtering): "patient", "therapist" or "admin"
  attr_reader :filtered # string name of objects being filtered: "obsessions", "plans" or "users"

  def initialize(filterer, filtered) # a filter instance is instantiated with 2 string attributes
    @filterer = filterer
    @filtered = filtered
  end
end
