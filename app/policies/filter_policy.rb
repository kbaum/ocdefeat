class FilterPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      filters = scope.all.delete_if {|filter| filter.filterer == "unassigned"}

      filters.delete_if {|filter| filter.filterer == "patient"} unless user.patient?
      filters.delete_if {|filter| filter.filterer == "therapist"} unless user.therapist?
      filters.delete_if {|filter| filter.filterer == "admin"} unless user.admin?

      filters
    end
  end
end

# filters stores this array:
# [
# #<Filter:0x007faeb284b2d8 @filterer="patient", @filtered="obsessions">,
# #<Filter:0x007faeb284b288 @filterer="patient", @filtered="plans">,
# #<Filter:0x007faeb284b238 @filterer="patient", @filtered="users">,
# #<Filter:0x007faeb284b1c0 @filterer="therapist", @filtered="obsessions">,
# #<Filter:0x007faeb284b170 @filterer="therapist", @filtered="plans">,
# #<Filter:0x007faeb284b120 @filterer="therapist", @filtered="users">,
# #<Filter:0x007faeb284b080 @filterer="admin", @filtered="obsessions">,
# #<Filter:0x007faeb284b030 @filterer="admin", @filtered="plans">,
# #<Filter:0x007faeb284afe0 @filterer="admin", @filtered="users">
# ]

# filters stores array of all filter instances representing the following situations:
# A patient viewing: their own obsessions, their own plans, users who are therapists
# A therapist viewing: patients' obsessions, patients' plans, users who are patients
# An admin viewing: patients' obsessions, patients' plans, all types of users
