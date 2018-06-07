class WizardsController < ApplicationController
  before_action :set_present_part, only: [:part1, :part2, :part3, :create]

  def validate_part
  end

  def part1 # implicitly renders app/views/wizards/part1.html.erb (1st part of signup form)
  end

  def part2 # implicitly renders app/views/wizards/part2.html.erb (2nd part of signup form)
  end

  def part3 # implicitly renders app/views/wizards/part3.html.erb (3rd part of signup form)
  end

  def create
  end

  private
    def instantiate_part(string_part) # valid argument = "part1", "part2" or "part3"
      #raise InvalidPart unless string_part.in?(Wizard::User::PARTS)
      raise InvalidPart unless Wizard::User::PARTS.include?(string_part)
      "Wizard::User::#{string_part.camelize}".constantize.new(session[:user_properties])
    end

    def set_present_part
      @present_part = instantiate_part(action_name)
    end

    def next_part(string_part)
      Wizard::User::PARTS[Wizard::User::PARTS.index(string_part) + 1]
    end
    # Wizard::User::PARTS = ["part1", "part2", "part3"]
    # If I'm currently on "part1," that's at index 0 of the array,
    # so the next part that I proceed to is found at Wizard::User:PARTS[1], which is "part2"

    def present_part_params
      params.require(:present_part).permit(
        :name,
        :email,
        :password,
        :password_confirmation,
        :role_requested,
        :severity,
        :variant
      )
    end

    class InvalidPart < StandardError; end
end
# instantiate_user_part(string_part) explanation:
# "part1".camelize returns "Part1", "part2".camelize returns "Part2", "part3".camelize returns "Part3"
# constantize tries to find a constant (in this case, the name of a class)
# named "Wizard::User::Part1" or "Wizard::User::Part2" or "Wizard::User::Part3"
# (with constantize, a NameError is raised when the name is not in CamelCase or the constant is unknown)
# We instantiate an instance of Wizard::User::Part1 or Wizard::User::Part2 or Wizard::User::Part3,
# passing in a hash of attributes of the AR user instance who's signing up

# instantiate_current_user_part explanation:
# Due to before_action code, before displaying each part of the multipart form,
# the #instantiate_current_user_part method is called.
# The method #instantiate_current_user_part uses the current action name (#part1, #part2 or #part3)
# to instantiate an instance of the current part class,
# i.e., to instantiate an instance of Wizard::User::Part1 or Wizard::User::Part2 or Wizard::User::Part3.
# @current_user_part stores this instance of the current part class, i.e.,
# stores an instance of Wizard::User::Part1 or Wizard::User::Part2 or Wizard::User::Part3,
# (which has a hash of the user's attribute data stored in session hash),
# depending on whatever the current part is

# validate_part explanation:
# Every time the user clicks the button to go to the next part of the multipart signup form,
# the method #validate_part is called.
# validate_part either redirects to the next part of the signup form,
# or, in the case of invalid user input, renders the current part again to display errors to the user
# Each time #validate_part is called when the user validates a part,
# we store all of the attributes of the user instance as a hash
# rather than storing the instance itself in the session hash)
