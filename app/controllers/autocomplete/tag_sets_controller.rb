# frozen_string_literal: true

class Autocomplete::TagSetsController < Autocomplete::BaseController
  before_action :set_current_user

  def index
    return if params[:term].blank?

    search_param = '%' + params[:term] + '%'
    render_output(
      OwnedTagSet.limit(10)
                 .order(:title)
                 .usable
                 .where("owned_tag_sets.title LIKE ?", search_param)
                 .collect(&:title)
    )
  end
end
