admin = User.new
admin.name = "Adelaide Adminski"
admin.email = "admin@ocdefeat.com"
admin.password = "ocdefeat"
admin.role = 3
admin.severity = "not_applicable"
admin.save

therapist = User.new
therapist.name = "Dr. Simon Therapinski, PsyD"
therapist.email = "psychologist@ocdefeat.com"
therapist.password = "psychology"
therapist.role = 2
therapist.severity = "not_applicable"
therapist.save
