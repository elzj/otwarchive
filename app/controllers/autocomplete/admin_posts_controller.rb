# frozen_string_literal: true

class Autocomplete::AdminPostsController < Autocomplete::BaseController

  # admin posts for translations, formatted as Admin Post Title (Post #id)
  def index
    return if params[:term].blank?

    search_param = '%' + params[:term] + '%'
    results = AdminPost.non_translated.where(
      "title LIKE ?", search_param).limit(ArchiveConfig.MAX_RECENT
    ).map do |result|
      {
        id: (post_id = result.id),
        name: result.title + " (Post ##{post_id})"
      }
    end
    respond_with(results)
  end

  def tags
    return if params[:term].blank?

    search_param = '%' + params[:term].strip + '%'
    query = AdminPostTag.where("name LIKE ?", search_param).limit(ArchiveConfig.MAX_RECENT)
    render_output(query.pluck(:name))
  end
end
