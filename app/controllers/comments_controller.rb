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

  private

    def comment_params
      params.require(:comment).permit(:content, :obsession_id, :user_id)
    end

    def comment_creation_msg
      if current_user.therapist?
        "Thank you for sharing your advice!"
      elsif current_user.patient?
        "Thank you for reaching out to our therapy team so we can effectively address your concerns!"
      end
    end
end
