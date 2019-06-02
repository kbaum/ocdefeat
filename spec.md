# Specifications for the Rails Assessment

Specs:
- [x] Using Ruby on Rails for the project
- [x] Include at least one has_many relationship (x has_many y e.g. User has_many Recipes)
User has_many Obsessions
Obsession has_many Plans
Obsession has_many Comments
Plan has_many Steps
- [x] Include at least one belongs_to relationship (x belongs_to y e.g. Post belongs_to User)
Obsession belongs_to User
Plan belongs_to Obsession
Step belongs_to Plan
Comment belongs_to Obsession, etc.
- [x] Include at least one has_many through relationship (x has_many y through z e.g. Recipe has_many Items through Ingredients)
User has_many Treatments through UserTreatments (user has_many :treatments, through: :user_treatments)
- [x] The "through" part of the has_many through includes at least one user submittable attribute (attribute_name e.g. ingredients.quantity) (efficacy and duration are stored in the user_treatments join table)
user_treatments.efficacy and user_treatments.duration
- [x] Include reasonable validations for simple model objects (list of model objects with validations e.g. User, Recipe, Ingredient, Item)
User, Obsession, Plan, Step, Theme, Treatment, Comment, UserTreatment
- [x] Include a class level ActiveRecord scope method (model object & class method name and URL to see the working feature e.g. User.most_recipes URL: /users/most_recipes
  User.symptomatic URL: /users/symptomatic
  (among several other ActiveRecord scope methods defined)
- [x] Include signup (how e.g. Devise)
get '/signup' => 'users#new' and post '/users' => 'users#create'
(the latter is provided by resources :users, except: :new)
(my own standard authentication logic)
- [x] Include login (how e.g. Devise)
get '/login' => 'sessions#new' and post '/login' => 'sessions#create' (my own standard authentication logic)
- [x] Include logout (how e.g. Devise)
delete '/logout' => 'sessions#destroy'(my own standard logic)
- [x] Include third party signup/login (how e.g. Devise/OmniAuth)
OmniAuth Twitter
- [x] Include nested resource show or index (URL e.g. users/2/recipes)
Nested resource index: obsessions/1/comments
(The patient/that patient's therapist can read comments about a particular obsession)
- [x] Include nested resource "new" form (URL e.g. recipes/1/ingredients)
Example 1: First, localhost:3000/obsessions/1/plans/new presents a form so the user with the role of patient can
create a new plan that automatically 'belongs to' the given obsession (in this case, the obsession with id = 1)
Then, form data is submitted via an HTTP POST request to /obsessions/1/plans, which maps to plans#create
Example 2: The user submits the form to add a new step to a plan on the plan show page, and form data is submitted via an HTTP POST request to /plans/1/steps, which maps to steps#create
Example 3: The user submits the form to create a new comment about an obsession (e.g. obsession with id = 1)
on that obsession's show page, and the form is submitted via an HTTP POST request to /obsessions/1/comments,
which maps to comments#create
- [x] Include form display of validation errors (form URL e.g. /recipes/new)
/signup (presents registration form)
/obsessions/new (presents new obsession form)
/obsessions/:obsession_id/plans/new (presents form to create a new plan for a particular obsession)
/plans/:id (presents form to create a new step in a plan on the plan show page)
/themes/new (presents form to create a new theme)
Confirm:
- [x] The application is pretty DRY
- [x] Limited logic in controllers
- [x] Views use helper methods if appropriate
- [x] Views use partials if appropriate
