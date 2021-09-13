# frozen_string_literal: true

module AutocompleteHelper

  # returns the default autocomplete attributes, all of which can be overridden
  # note: we do this and put the message defaults here so we can use translation on them
  def autocomplete_options(autocomplete, options={})
    autocomplete = autocomplete_mapper(autocomplete)
    autocomplete_method = if autocomplete.is_a?(Array)
                            autocomplete.to_json
                          else
                            "/autocomplete/#{autocomplete}"
                          end
    {
      class: "autocomplete",
      data: {
        autocomplete_method: autocomplete_method,
        autocomplete_hint_text: ts("Start typing for suggestions!"),
        autocomplete_no_results_text: ts("(No suggestions found)"),
        autocomplete_min_chars: 1,
        autocomplete_searching_text: ts("Searching...")
      }
    }.deep_merge(options)
  end

  private

  def autocomplete_mapper(autocomplete)
    if %w(fandom character relationship freeform).include?(autocomplete)
      "tags?type=#{autocomplete}"
    elsif %w(character_in_fandom relationship_in_fandom).include?(autocomplete)
      tag_type = autocomplete.split("_").first
      "tags/in_fandom?tag_type=#{tag_type}"
    else
      autocomplete
    end
  end
end
