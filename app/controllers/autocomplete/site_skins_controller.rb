# frozen_string_literal: true

class Autocomplete::SiteSkinsController < Autocomplete::BaseController
  before_action :set_current_user

  def index
    return if params[:term].blank?

    search_param = '%' + params[:term] + '%'
    query = Skin.site_skins.where("title LIKE ?", search_param).limit(15).sort_by_recent
    if logged_in?
      query = query.approved_or_owned_by(current_user)
    else
      query = query.approved_skins
    end
    render_output(query.pluck(:title))
  end
end
