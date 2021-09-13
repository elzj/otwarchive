# frozen_string_literal: true

class Autocomplete::CollectionsController < Autocomplete::BaseController
  before_action :set_current_user, only: [:parent_name]

  # look up collections ranked by number of items they contain
  def index
    results = Collection.autocomplete_lookup(
      search_param: params[:term],
      autocomplete_prefix: "autocomplete_collection_all"
    ).map { |result| Collection.fullname_from_autocomplete(result) }
    render_output(results)
  end

  def open
    # in this case we want different ids from names so we can
    # display the title but only put in the name
    results = Collection.autocomplete_lookup(
      search_param: params[:term],
      autocomplete_prefix: "autocomplete_collection_open"
    ).map do |str|
      {
        id: (whole_name = Collection.name_from_autocomplete(str)),
        name: Collection.title_from_autocomplete(str) + " (#{whole_name})"
      }
    end
    respond_with(results)
  end

  # For creating collections, autocomplete the name of a parent collection owned by the user only
  def parent_name
    render_output(
      current_user.maintained_collections.top_level.with_name_like(params[:term]).pluck(:name).sort
    )
  end
end
