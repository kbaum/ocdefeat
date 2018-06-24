class CommentsController < ApplicationController
  before_action :set_comment, only: [:edit, :update, :destroy]

  def create # POST request to "/obsessions/:obsession_id/comments" maps to comments#create
    @comment = current_user.comments.build(comment_params)
    authorize @comment
    if @comment.save
      redirect_to obsession_comments_path(@comment.obsession), notice: "#{comment_creation_msg}"
    else
      flash.now[:error] = "Your attempt to comment on the obsession was unsuccessful. Please try again."
      render :edit
    end
  end

  def edit  # GET "/comments/:id/edit" maps to comments#edit due to shallow nesting
    authorize @comment
  end

  def update # PUT or PATCH request to "/comments/:id" maps to comments#update due to shallow nesting
    authorize @comment
    if @comment.update_attributes(permitted_attributes(@comment))
      redirect_to obsession_comments_path(@comment.obsession), notice: "Your comment was successfully modified!"
    else
      flash.now[:error] = "Your attempt to edit this comment was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy  # DELETE request to "/comments/:id" maps to comments#destroy
    authorize @comment
    @comment.destroy
    redirect_to obsessions_path, notice: "#{delete_comment_message}"
  end

  def index # Route helper #obsession_comments_path returns "/obsessions/:obsession_id/comments", which maps to comments#index
    @obsession = Obsession.find(params[:obsession_id])
    @comments = @obsession.comments
    @user = @obsession.user
    authorize @user, :show_comments?

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

    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:content, :obsession_id, :user_id)
    end

    def comment_creation_msg
      if current_user.therapist?
        "Thank you for sharing your advice about overcoming this obsession!"
      elsif current_user.patient?
        "Thank you for reaching out to your therapist!"
      end
    end

    def commenter
      if current_user.patient?
        "You"
      elsif current_user.therapist?
        "The patient"
      end
    end

    def delete_comment_message
      if current_user.therapist?
        "Your comment was successfully deleted. Would you like to psychoanalyze another obsession?"
      elsif current_user.patient?
        "Your comment was successfully deleted. Would you like to voice a concern about a different obsession?"
      end
    end
  end
