class FandomCountriesController < ApplicationController
  
  def index
    @countries = FandomCountry.order(:name)
  end
  
  def show
    @country = FandomCountry.find_by_name(params[:id])
    @fandoms = @country.fandoms.order(:name).page(params[:page])
  end
  
end