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

    if !params[:type].blank? # If the user filters comments by type
      if params[:type] == "Patient Concerns"
        if @obsession.comments.concerns.empty?
          flash.now[:alert] = "#{commenter} voiced no concerns about this obsession."
        else
          @comments = @obsession.comments.concerns
          flash.now[:notice] = "#{commenter} voiced #{@comments.count} #{'concern'.pluralize(@comments.count)} about this obsession."
        end
      elsif params[:type] == "Advice from Therapists"
        if @obsession.comments.advice.empty?
          flash.now[:alert] = "Unfortunately, no therapy pointers were given to #{commenter.downcase}."
        else
          @comments = @obsession.comments.advice
          flash.now[:notice]= "#{commenter} should bear #{@comments.count} therapy #{'pointer'.pluralize(@comments.count)} in mind when struggling with this obsession."
        end
      end
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
