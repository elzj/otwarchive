class FandomMediaController < ApplicationController
  
  def index
    @media = FandomMedium.order(:name)
  end
  
  def show
    @medium = FandomMedium.find_by_name(params[:id])
    @fandoms = @medium.fandoms.order(:name).page(params[:page])
  end
  
end