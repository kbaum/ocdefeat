class CommentsController < ApplicationController
  before_action :set_comment, only: [:update, :destroy]

  def create # POST request to "/obsessions/:obsession_id/comments" maps to comments#create
    @comment = current_user.comments.build(comment_params)
    authorize @comment
    if @comment.save
      redirect_to obsession_comments_path(@comment.obsession), flash: { success: "#{comment_creation_msg}" }
    else
      flash.now[:error] = "Your attempt to comment on the obsession was unsuccessful. Please try again."
      render :edit
    end
  end

  def edit  # GET "/comments/:id/edit" maps to comments#edit due to shallow nesting
    @comment = Comment.find(params[:id]).decorate
    authorize @comment
  end

  def update # PUT or PATCH request to "/comments/:id" maps to comments#update due to shallow nesting
    authorize @comment
    if @comment.update_attributes(permitted_attributes(@comment))
      redirect_to obsession_comments_path(@comment.obsession), flash: { success: "Your comment was successfully modified!" }
    else
      flash.now[:error] = "Your attempt to edit this comment was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy  # DELETE request to "/comments/:id" maps to comments#destroy
    authorize @comment
    @comment.destroy
    redirect_to obsessions_path, flash: { success: "#{delete_comment_message}" }
  end

  def index # Route helper #obsession_comments_path returns "/obsessions/:obsession_id/comments", which maps to comments#index
    @obsession = Obsession.find(params[:obsession_id]).decorate
    @comments = policy_scope(Comment).where(obsession: @obsession).decorate # stores all comments on a single obsession (concerns and advice)
    patient_obsessing = @obsession.user # stores the patient who reported the obsession
    authorize patient_obsessing, :show_comments? # A patient can see all comments on her own obsessions. A therapist can see all comments on her own patients' obsessions.

    if params[:type] == "Patient Concerns"
      if @comments.concerns.empty?
        flash.now[:alert] = "#{commenter} voiced no further concerns about this obsession, but here are some therapy tips to keep in mind:"
      else
        @comments = @comments.concerns.decorate # stores all concerns on a single obsession
        flash.now[:notice] = "#{commenter} voiced #{@comments.count} #{'concern'.pluralize(@comments.count)} about this obsession."
      end
    elsif params[:type] == "Advice from Therapists"
      if @comments.advice.empty?
        flash.now[:alert] = "Unfortunately, no therapy pointers were given to #{commenter.downcase}, but here are some concerns that need to be addressed:"
      else
        @comments = @comments.advice.decorate # stores all advice on a single obsession
        flash.now[:notice]= "#{commenter} should bear #{@comments.count} therapy #{'pointer'.pluralize(@comments.count)} in mind when overcoming this obsession."
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
        "Thank you for reaching out to your therapist to express your concerns!"
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
