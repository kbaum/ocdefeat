class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      redirect_to obsession_path(@comment.obsession)
    else
      flash.now[:error] = "Your attempt to comment on this obsession was unsuccessful. Please try again."
      render "obsessions/show"
    end
  end

  private

    def comment_params
      params.require(:comment).permit(:content, :obsession_id)
    end
end
