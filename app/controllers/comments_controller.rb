class CommentsController < ApplicationController
  before_action :set_comment, only: [:edit, :update, :destroy]

  def create # POST request to "/obsessions/:obsession_id/comments" maps to comments#create
    @obsession = Obsession.find(params[:obsession_id]).decorate # Immediately decorate b/c no changes made in DB before presenting view
    comment = current_user.comments.build(comment_params)
    if comment.save # try saving to DB *before* presenting view, so DON'T decorate yet
      @comment = comment.decorate # Decorate right before presenting comments index view
      redirect_to obsession_comments_path(@obsession), flash: { success: @comment.creation_message }
    else # comment was invalid and not saved to the DB
      @comment = comment.decorate # @comment is populated with errors, but _comment_form needs this comment instance to be decorated for methods like #label
      render "obsessions/show" # present form with validation errors on obsession show view
      flash.now[:error] = "Your attempt to comment on this obsession was unsuccessful. Please try again."
    end
  end

  def edit  # GET "/comments/:id/edit" maps to comments#edit due to shallow nesting
    comment = Comment.find(params[:id])
    authorize comment
    @comment = comment.decorate # decorate right before rendering app/views/comments/edit.html.erb (_comment_form needs decorated comment)
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
      comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:content, :obsession_id, :user_id)
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
