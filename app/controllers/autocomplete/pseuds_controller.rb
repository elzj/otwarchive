# frozen_string_literal: true

class Autocomplete::PseudsController < Autocomplete::BaseController
  def index
    if params[:term].blank?
      # get the user's own pseuds
      set_current_user
      render_output(current_user.pseuds.collect(&:byline))
    else
      render_output(
        Pseud.autocomplete_lookup(
          search_param: params[:term],
          autocomplete_prefix: "autocomplete_pseud"
        ).map { |entry| Pseud.fullname_from_autocomplete(entry) }
      )
    end
  end
end
