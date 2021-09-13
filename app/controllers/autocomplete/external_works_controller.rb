# frozen_string_literal: true

class Autocomplete::ExternalWorksController < Autocomplete::BaseController
  # for looking up existing urls for external works to avoid duplication
  def index
    render_output(
      ExternalWork.where(
        ["url LIKE ?", '%' + params[:term] + '%']
      ).limit(10).order(:url).pluck(:url)
    )
  end
end
