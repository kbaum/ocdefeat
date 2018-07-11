class CommentDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all
end
