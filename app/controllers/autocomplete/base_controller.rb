# frozen_string_literal: true

class Autocomplete::BaseController < ApplicationController
  respond_to :json

  skip_before_action :store_location
  skip_before_action :fetch_admin_settings
  skip_before_action :set_redirects
  skip_before_action :set_current_user
  skip_before_action :sanitize_ac_params # can we dare!

  private

  # Because of the respond_to :json at the top of the controller, this will return a JSON-encoded
  # response which the autocomplete javascript on the other end should be able to handle :)
  def render_output(result_strings)
    if result_strings.first.is_a?(String)
      respond_with(result_strings.map { |str| { id: str, name: str } })
    else
      respond_with(result_strings)
    end
  end
end
