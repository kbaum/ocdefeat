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
    authorize @comment # retrieved from #set_comment
    @comment = @comment.decorate # decorate right before rendering app/views/comments/edit.html.erb (_comment_form needs decorated comment)
  end

  def update # PUT or PATCH request to "/comments/:id" maps to comments#update due to shallow nesting
    authorize @comment # retrieved from #set_comment
    if @comment.update_attributes(permitted_attributes(@comment))
      @comment = @comment.decorate # decorate *after* updating comment instance in DB, right before presenting view
      redirect_to obsession_comments_path(@comment.obsession), flash: { success: "Your comment was successfully modified!" }
    else # the comment needs to be decorated for _comment_form
      @comment = @comment.decorate
      render :edit
      flash.now[:error] = "Your attempt to edit this comment was unsuccessful. Please try again."
    end
  end

  def destroy  # DELETE request to "/comments/:id" maps to comments#destroy
    authorize @comment
    @comment.destroy
    redirect_to obsessions_path, flash: { success: "Your comment was successfully deleted. Would you like to comment on another obsession?" }
  end

  def index # Route helper #obsession_comments_path returns "/obsessions/:obsession_id/comments", which maps to comments#index
    @obsession = Obsession.find(params[:obsession_id]).decorate
    commenter = @obsession.patient_name
    comments = policy_scope(Comment).where(obsession: @obsession)
    patient_obsessing = @obsession.user # stores the patient who reported the obsession
    authorize patient_obsessing, :show_comments? # A patient can see all comments on her own obsessions. A therapist can see all comments on her own patients' obsessions.

    if params[:type] == "Patient Concerns"
      if comments.concerns.empty?
        flash.now[:alert] = "#{commenter} voiced no further concerns about this obsession."
      else
        @comments = comments.concerns.decorate
        flash.now[:notice] = "#{commenter} voiced #{@comments.count} #{'concern'.pluralize(@comments.count)} about this obsession."
      end
    elsif params[:type] == "Advice from Therapists"
      if comments.advice.empty?
        flash.now[:alert] = "Unfortunately, no therapy pointers were given to #{commenter}."
      else
        @comments = comments.advice.decorate
        flash.now[:notice]= "#{commenter} should bear #{@comments.count} therapy #{'pointer'.pluralize(@comments.count)} in mind when overcoming this obsession."
      end
    else # No filter chosen
      @comments = comments.decorate
    end
  end

  private

    def set_comment
      @comment = Comment.find(params[:id])
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
  end
