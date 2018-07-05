admin = User.new
admin.name = "Adela Adminski"
admin.email = "admin@ocdefeat.com"
admin.password = "ocdefeat"
admin.role = 3
admin.variant = "Neither"
admin.severity = "Nonobsessive"
admin.role_requested = "Admin"
admin.save

first_therapist = User.new
first_therapist.name = "Dr. Theodore Therapinski"
first_therapist.email = "psychologist@ocdefeat.com"
first_therapist.password = "psychology"
first_therapist.role = 2
first_therapist.variant = "Neither"
first_therapist.severity = "Nonobsessive"
first_therapist.role_requested = "Therapist"
first_therapist.save

second_therapist = User.new
second_therapist.name = "Dr. Simon Psychiatritski"
second_therapist.email = "psychiatrist@ocdefeat.com"
second_therapist.password = "psychiatry"
second_therapist.role = 2
second_therapist.variant = "Neither"
second_therapist.severity = "Nonobsessive"
second_therapist.role_requested = "Therapist"
second_therapist.save

first_patient = User.new
first_patient.name = "Raymond"
first_patient.email = "patient1@ocdefeat.com"
first_patient.password = "love2code"
first_patient.role = 1
first_patient.variant = "Purely Obsessional"
first_patient.severity = "Mild"
first_patient.role_requested = "Patient"
first_patient.counselor = first_therapist
first_patient.save

second_patient = User.new
second_patient.name = "Delilah"
second_patient.email = "patient2@ocdefeat.com"
second_patient.password = "live4coding"
second_patient.role = 1
second_patient.variant = "Traditional"
second_patient.severity = "Moderate"
second_patient.role_requested = "Patient"
second_patient.counselor = second_therapist
second_patient.save

Treatment.create(treatment_type: "Psychotherapy")
Treatment.create(treatment_type: "Cognitive Behavioral Therapy (CBT)")
Treatment.create(treatment_type: "Exposure and Response Prevention (ERP)")
Treatment.create(treatment_type: "Imaginal Exposure")
Treatment.create(treatment_type: "Behavior Modification")
Treatment.create(treatment_type: "Group Therapy")
Treatment.create(treatment_type: "Traditional Outpatient Clinic")
Treatment.create(treatment_type: "Intensive Outpatient Clinic")
Treatment.create(treatment_type: "Inpatient")
Treatment.create(treatment_type: "Acceptance and Commitment Therapy")
Treatment.create(treatment_type: "Selective Serotonin Reuptake Inhibitors (SSRIs)")

Theme.create(name: "Existentialism", description: "This theme is characterized by preoccupation with philosophical questions about the meaning of life.", user_id: 2)
Theme.create(name: "Perfectionism", description: "This theme is characterized by preoccupation with making mistakes and the need to exert absolute control.", user_id: 3)
Theme.create(name: "Contamination", description: "This theme is characterized by the fear of being exposed to contaminants, including germs, illnesses and toxic substances.", user_id: 2)
Theme.create(name: "Scrupulosity", description: "This theme is characterized by preoccupation with religious and moral values.", user_id: 3)
Theme.create(name: "Sensorimotor OCD", description: "This theme is characterized by hyperfixation on automatic bodily processes such as swallowing, breathing or blinking.", user_id: 2)
Theme.create(name: "Symmetry and Orderliness", description: "This theme is characterized by the urge to arrange one's environment in a precise and rigid way.", user_id: 3)

UserTreatment.create(user_id: 2, treatment_id: 3, efficacy: "extremely effective", duration: "may take months to years to master this technique")
UserTreatment.create(user_id: 2, treatment_id: 11, efficacy: "best when used in conjunction with ERP", duration: "typically lifelong")
UserTreatment.create(user_id: 2, treatment_id: 1, efficacy: "helpful to confide in someone you trust", duration: "months to years")
