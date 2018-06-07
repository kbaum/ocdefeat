module Wizard
  module User
    PARTS = %w(part1 part2 part3).freeze # PARTS stores the immutable array ["part1", "part2", "part3"]

    class Base
      include ActiveModel::Model # I can use instances of wizard form classes in Rails forms and access default Rails validations
    end
  end
end
