# README
OCDefeat is a Rails application that facilitates the design and implementation of treatment plans for patients diagnosed with Obsessive Compulsive Disorder (OCD). This application enables patients and mental health professionals to collaborate in the development of Exposure and Response Prevention (ERP) plans, a treatment approach
by which repeated exposure to fears and avoidance of ritualization leads to increased anxiety tolerance.

During the registration process, prospective users request a role in the OCDefeat community, which the admin can approve or reject. After their roles have been assigned, newly-minted OCDefeat patients can report their obsessions, voice concerns and develop custom ERP plans tailored to their obsessions. Therapists, who are assigned to particular patients by the admin, can revise their patients' ERP plans, create OCD themes in which to classify their patients' obsessions and provide advice.

Please follow the instructions below:

1). Fork this repository
2). Install all gem dependencies by running bundle install (or bundle)
3). Run migrations with the command rake db:migrate to set up the database
3). Seed your database by running rake db:seed
4). Run command rails s start up your application's local server
5). Navigate to http://localhost:3000/ to start using OCDefeat!

Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Jenna424/ocdefeat. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

License

The application is available as open source under the terms of the MIT License.
