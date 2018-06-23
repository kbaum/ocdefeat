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

  def update
    authorize @comment
    if @comment.update(comment_params)
      redirect_to obsession_path(@obsession), notice: "Your comment was successfully updated!"
    else
      flash.now[:error] = "Your attempt to edit this comment was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy
    authorize @comment
    @comment.destroy
    redirect_to obsession_path(@obsession), notice: "Your comment was successfully deleted!"
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
      @obsession = Obsession.find(params[:obsession_id])
      @comment = @obsession.comments.find(params[:id])
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
  end
