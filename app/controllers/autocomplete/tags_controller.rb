# frozen_string_literal: true

class Autocomplete::TagsController < Autocomplete::BaseController

  def index
    tag_output(params[:term], params[:type] || "all")
  end

  ## TAGS IN FANDOMS
  def in_fandom
    tag_in_fandom_output(params)
  end

  ## TAGS IN SETS
  #
  # Note that only tagsets in OwnedTagSets are in autocomplete
  #

  # expects the following params:
  # :tag_set - tag set ids comma-separated
  # :tag_type - tag type as a string unless "all" desired
  # :in_any - set to false if only want tags in ALL specified sets
  # :term - the search term
  def in_sets
    results = TagSet.autocomplete_lookup(params)
    render_output(
      results.map { |result| Tag.name_from_autocomplete(result) }
    )
  end

  # expects the following params:
  # :fandom - fandom name(s) as an array or a comma-separated string
  # :tag_set - tag set id(s) as an array or a comma-separated string
  # :tag_type - tag type as a string unless "all" desired
  # :include_wrangled - set to false if you only want tags from the set associations and NOT tags wrangled into the fandom
  # :fallback - set to false to NOT do
  # :term - the search term
  def associated
    if params[:fandom].blank?
      render_output([ts("Please select a fandom first!")])
    else
      results = TagSetAssociation.autocomplete_lookup(params)
      render_output(
        results.map { |result| Tag.name_from_autocomplete(result) }
      )
    end
  end

  ## NONCANONICAL TAGS
  def noncanonical
    search_param = params[:term]
    unless Tag::TYPES.include?(params[:type].classify)
      raise "Redshirt: Attempted to constantize invalid class initialize noncanonical_tag #{params[:type].classify}"
    end
    tag_class = params[:type].classify.constantize
    render_output(
      tag_class.by_popularity
               .where(
                 [
                   "canonical = 0 AND name LIKE ?",
                   '%' + search_param + '%'
                 ]
               ).limit(10).map(&:name)
    )
  end

  # Nominated parents
  def nominated_parents
    render_output(
      TagNomination.for_tag_set(
        OwnedTagSet.find(params[:tag_set_id])
      ).nominated_parents(params[:tagname], params[:term]))
  end


  private

  def tag_output(search_param, tag_type)
    tags = Tag.autocomplete_lookup(
      search_param: search_param,
      autocomplete_prefix: "autocomplete_tag_#{tag_type}"
    )
    render_output tags.map { |result| Tag.name_from_autocomplete(result) }
  end

  def tag_in_fandom_output(params)
    render_output(
      Tag.autocomplete_fandom_lookup(params).map { |result| Tag.name_from_autocomplete(result) }
    )
  end
end
