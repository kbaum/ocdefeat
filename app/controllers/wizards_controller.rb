class WizardsController < ApplicationController
  def part1 # implicitly renders app/views/wizards/part1.html.erb (1st part of signup form)
  end

  def part2 # implicitly renders app/views/wizards/part2.html.erb (2nd part of signup form)
  end

  def part3 # implicitly renders app/views/wizards/part3.html.erb (3rd part of signup form)
  end

  private
    def instantiate_user_part(string_part) # valid argument = "part1", "part2" or "part3"
      raise InvalidPart unless string_part.in?(Wizard::User::PARTS)
      "Wizard::User::#{part.camelize}".constantize.new(session[:user_properties])
    end

    class InvalidPart < StandardError; end

end
# "part1".camelize returns "Part1", "part2".camelize returns "Part2", "part3".camelize returns "Part3"
# constantize tries to find a constant (in this case, the name of a class)
# named "Wizard::User::Part1" or "Wizard::User::Part2" or "Wizard::User::Part3"
# (with constantize, a NameError is raised when the name is not in CamelCase or the constant is unknown)
# We instantiate an instance of Wizard::User::Part1 or Wizard::User::Part2 or Wizard::User::Part3,
# passing in a hash of attributes of the AR user instance who's signing up
