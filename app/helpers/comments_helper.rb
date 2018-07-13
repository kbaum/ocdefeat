module CommentsHelper
  def new_or_invalid(comment)
    comment.errors.any? ? comment : Comment.new.decorate
  end
end
