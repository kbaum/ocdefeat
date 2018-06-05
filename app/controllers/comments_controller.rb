class CommentsController < ApplicationController
  def create
    @comment = current_user.comments.build(comment_params)
    if @comment.save
      redirect_to obsession_path(@comment.obsession), notice: "#{comment_creation_msg}"
    else
      flash.now[:error] = "Your attempt to comment on the obsession was unsuccessful. Please try again."
      render :edit
    end
  end

  def index # Route helper obsession_comments_path returns "/obsessions/:obsession_id/comments", which maps to comments#index
    @obsession = Obsession.find(params[:obsession_id])
    @comments = @obsession.comments
  end

  private

    def comment_params
      params.require(:comment).permit(:content, :obsession_id, :user_id)
    end

    def comment_creation_msg
      if current_user.therapist?
        "Thanks for sharing your advice!"
      elsif current_user.patient?
        "Thanks for reaching out to our therapy team so we can effectively address your concerns!"
      end
    end
end
