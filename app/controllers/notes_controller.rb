class NotesController < ApplicationController
  before_action :set_note, only: [:edit, :update, :destroy]

  def edit
  end

  def update
  end

  def destroy
  end

  private

    def set_note
      @note = User.find(params[:user_id]).notes.find(params[:id])
    end
end
