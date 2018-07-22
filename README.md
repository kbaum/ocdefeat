# README
OCDefeat is a Ruby on Rails application that enables patients and mental health professionals to collaborate in the development and implementation of Exposure and Response Prevention (ERP) plans, a therapy technique that is commonly used in the treatment of Obsessive Compulsive Disorder (OCD). The premise of ERP is that patients develop anxiety tolerance and become habituated to fearful stimuli through repeated exposure to triggers and avoidance of ritualization.

During the registration process, prospective users request a role in the OCDefeat community. After their roles have been formally assigned by an admin, newly-minted OCDefeat patients can record their obsessions, voice their concerns about a particular obsession and establish personal goals for themselves when selecting a treatment approach and structuring ERP plans. Therapists, who are assigned a patient caseload by the admin, can add OCD themes in which to classify their patients' obsessions, filter obsessions, provide advice about overcoming obsessions and facilitate the design of treatment plans by contributing, editing or deleting steps in each plan. OCDefeat administrators have the ability to assign roles and manage users accounts.

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
