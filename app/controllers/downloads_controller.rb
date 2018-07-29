class DownloadsController < ApplicationController

  skip_before_action :store_location, only: :show
  before_action :load_work, only: :show
  before_action :check_visibility, only: :show
  after_action :remove_downloads, only: :show

  def show
    respond_to :html, :pdf, :mobi, :epub
    unless params[:dont_generate_download]
      @download = Download.generate(@work, mime_type: request.format)
    end

    # Make sure we were able to generate the download
    unless @download.present? && @download.exists?
      flash[:error] = ts('We were not able to render this work. Please try again in a little while or try another format.')
      redirect_to work_path(@work)
      return
    end

    # send file synchronously so we don't delete it before we have finished sending it
    File.open(@download.file_path, 'r') do |f|
      send_data f.read, filename: "#{@download.file_name}.#{@download.file_type}", type: @download.mime_type
    end
  end

protected

  # Set up the work and check revealed status
  # once a format has been created, we want nginx to be able to serve
  # it directly, without going through rails again (until the work changes).
  # This means no processing per user. consider this the "published" version
  # It can't contain unposted chapters, nor unrevealed authors, even
  # if the author is the one requesting the download
  def load_work
    @work = Work.find(params[:id])

    if @work.in_unrevealed_collection?
      flash[:error] = ts("Sorry, you can't download an unrevealed work.")
      redirect_to work_path(@work)
      return
    end

    # set this for checking visibility
    @check_visibility_of = @work
  end

  # We're currently just writing everything to tmp and feeding them through nginx
  # so we don't want to keep the files around
  def remove_downloads
    @download&.remove unless Rails.env.test?
  end
end
