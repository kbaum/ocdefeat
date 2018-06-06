class SearchesController < ApplicationController
  def new
    @search = Search.new
  end

  def create
    @search = Search.create(search_params)
    redirect_to search_path(@search), notice: "Your search results are displayed below."
  end

  def show
    @search = Search.find(params[:id])
  end

  private

    def search_params
      params.require(:search).permit(
        :key_terms,
        :user_id,
        :min_anxiety_rating,
        :max_anxiety_rating
      )
    end
end
