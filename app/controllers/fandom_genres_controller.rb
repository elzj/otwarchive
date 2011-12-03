class FandomGenresController < ApplicationController
  
  def index
    @genres = FandomGenre.order(:name)
  end
  
  def show
    @genre = FandomGenre.find_by_name(params[:id])
    @fandoms = @genre.fandoms.order(:name).page(params[:page])
  end
  
end