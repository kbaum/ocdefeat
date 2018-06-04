class NotesController < ApplicationController
  def new
    @note = Note.new
  end

  def edit
  end
end
