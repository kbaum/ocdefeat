module Wizard
  module User
    PARTS = %w(part1 part2 part3).freeze # PARTS stores the immutable array ["part1", "part2", "part3"]

    class Base
      include ActiveModel::Model # I can use instances of wizard form classes in Rails forms and access default Rails validations
      attr_accessor :user

      def initialize(user_properties)
        @user = ::User.new(user_properties)
      end
    end
  end
end
