# README
OCDefeat is a Ruby on Rails application that enables patients and mental health professionals to collaborate in the development and implementation of Exposure and Response Prevention (ERP) plans, a therapy technique that is commonly used in the treatment of Obsessive Compulsive Disorder (OCD). The premise of ERP is that patients develop anxiety tolerance and become habituated to fearful stimuli through repeated exposure to triggers and avoidance of ritualization.

During the registration process, prospective users request a role in the OCDefeat community. After their roles have been formally assigned by an admin, newly-minted OCDefeat patients can record their obsessions, voice their concerns about a particular obsession and establish personal goals for themselves when selecting a treatment approach and structuring ERP plans. Therapists, who are assigned a patient caseload by the admin, can add OCD themes in which to classify their patients' obsessions, filter obsessions, provide advice about overcoming obsessions and facilitate the design of treatment plans by contributing, editing or deleting steps in each plan. OCDefeat administrators have the ability to assign roles and manage users accounts.

# Installation Guide
1. Fork and clone this repository
2. Install all gem dependencies by running bundle install (or bundle)
3. Run migrations with the command rake db:migrate to set up the database
4. Seed your database by running rake db:seed
5. Run command rails s to start up your application's local server
6. Navigate to http://localhost:3000/ to start using OCDefeat!

# Contributors' Guide
1. Please fork and clone this repository.
2. Run bundle install (or bundle) to install/update gems
3. Make any changes you see fit, such as the addition of a new feature or a big fix.
4. Concisely and clearly document any changes you make with a descriptive commit message!
5. Send a pull request.
Bug reports and pull requests are welcome on GitHub at https://github.com/Jenna424/ocdefeat. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

# License

This project has been licensed under the MIT open source license.
[Read the LICENSE.md file in this repository](LICENSE.md)

MIT License

Copyright (c) 2018 Jenna424

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
