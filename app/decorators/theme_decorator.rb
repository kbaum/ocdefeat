class ThemeDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all
end
