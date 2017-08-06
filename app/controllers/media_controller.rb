class MediaController < ApplicationController
  before_filter :load_collection
  skip_before_filter :store_location, only: [:show]

  def index
    uncategorized = Media.uncategorized
    @media = Media.by_name - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME), uncategorized] + [uncategorized]
    @fandom_listing = Media.top_fandoms(logged_in: is_registered_user?)
    @page_subtitle = ts("Fandoms")
  end

  def show
    redirect_to medium_fandoms_path(medium_id: params[:id])
  end
end
