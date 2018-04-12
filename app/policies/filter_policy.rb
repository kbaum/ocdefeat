class FilterPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      filters = scope.all # all filter instances

      filters.delete_if {|filter| filter.filterer == "patient"} unless user.patient?
      filters.delete_if {|filter| filter.filterer == "therapist"} unless user.therapist?
      filters.delete_if {|filter| filter.filterer == "admin"} unless user.admin?

      filters
    end
  end
end

# filters stores this array:
# [
# #<Filter:0x007f93ed33c8f8 @filterer="patient", @filtered="obsessions">,
# #<Filter:0x007f93ed33c8a8 @filterer="patient", @filtered="plans">,
# #<Filter:0x007f93ed33c830 @filterer="patient", @filtered="users">,
# #<Filter:0x007f93ed33c7b8 @filterer="therapist", @filtered="obsessions">,
# #<Filter:0x007f93ed33c768 @filterer="therapist", @filtered="plans">,
# #<Filter:0x007f93ed33c718 @filterer="therapist", @filtered="users">,
# #<Filter:0x007f93ed33c678 @filterer="admin", @filtered="obsessions">,
# #<Filter:0x007f93ed33c628 @filterer="admin", @filtered="plans">,
# #<Filter:0x007f93ed33c5b0 @filterer="admin", @filtered="users">
# ]
