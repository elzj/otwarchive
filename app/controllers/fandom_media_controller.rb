class FandomMediaController < ApplicationController
  
  def index
    @media = FandomMedium.where(:parent_id => nil, :featured => true).order(:name)
    @fandoms_all_time = Fandom.public_top(10)
    @fandoms_active = Fandom.public_top(10)
    @fandoms_new = Fandom.canonical.order("created_at DESC").limit(10)
    @fandoms_spotlight = Fandom.order("taggings_count DESC").offset(34).limit(10)
  end
  
  def show
    @medium = FandomMedium.find_by_slug(params[:id])
    @fandoms = @medium.fandoms.order(:name).page(params[:page])
  end
  
end