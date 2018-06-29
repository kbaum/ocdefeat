# README
OCDefeat is a Rails application that facilitates the design and implementation of treatment plans for patients diagnosed with Obsessive Compulsive Disorder (OCD). This application enables patients and mental health professionals to collaborate in the development of Exposure and Response Prevention (ERP) plans, a treatment approach
by which repeated exposure to fears and avoidance of ritualization leads to increased anxiety tolerance.

During the registration process, prospective users request a role in the OCDefeat community, which the admin can approve or reject. After their roles have been assigned, newly-minted OCDefeat patients can report their obsessions, voice concerns and develop custom ERP plans tailored to their obsessions. Therapists, who are assigned to particular patients by the admin, can revise their patients' ERP plans, create OCD themes in which to classify their patients' obsessions and provide advice.

Follow the instructions below to begin using OCDefeat:

1). Fork the repository
2). Run command bundle (or bundle install)
3). Run command rake db:seed (to seed the database)
4). Run command rails s to start this application on your local server, which can be viewed at: http://localhost:3000/
