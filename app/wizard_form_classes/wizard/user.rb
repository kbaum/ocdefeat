module Wizard
  module User
    PARTS = %w(part1 part2 part3).freeze # PARTS stores the immutable array ["part1", "part2", "part3"]

    class Base
      include ActiveModel::Model # I can use instances of wizard form classes in Rails forms and access default Rails validations
      attr_accessor :user # store AR user instance in user attribute to easily access the instance and save it on the final part of wizard form

      delegate *::User.attribute_names.collect {|attr_name| [attr_name, "#{attr_name}="]}.flatten, to: :user

      def initialize(user_properties)
        @user = ::User.new(user_properties)
      end
    end
  end
end
# User.attribute_names returns this array:
# ["id", "name", "email", "password_digest", "uid", "created_at", "updated_at", "severity", "role", "role_requested", "provider", "variant"]
# Calling #collect on this array returns an array of values resulting from invoking the block once on each array element:
# The delegate macro accepts several methods
# Use delegate macro to map all the attributes of the user instance inside all the form parts classes
# We're delegating these getter and setter instance methods (for all the user's attributes) to the user instance:
# ["id", "id=", "name", "name=", "email", "email=", "password_digest", "password_digest=", "uid", "uid=", "created_at", "created_at=", "updated_at", "updated_at=", "severity", "severity=", "role", "role=", "role_requested", "role_requested=", "provider", "provider=", "variant", "variant="]
