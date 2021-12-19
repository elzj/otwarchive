# frozen_string_literal: true

class Autocomplete::PotentialMatchesController < Autocomplete::BaseController
  # the pseuds of the potential matches who could fulfill the requests in the given signup
  def offers
    potential_matches(match_type: :offer)
  end

  # the pseuds of the potential matches who want the offers in the given signup
  def requests
    potential_matches(match_type: :request)
  end

  private

  # Return matching potential requests or offers
  def potential_matches(match_type:)
    search_param = params[:term]
    signup_id = params[:signup_id]
    signup = ChallengeSignup.find(signup_id)
    pmatches = signup_offer.public_send("#{match_type}_potential_matches")
                           .sort
                           .reverse
                           .map { |pm| pm.offer_signup.pseud.byline }
    pmatches.select! { |pm| pm.match(/#{Regexp.escape(search_param)}/) } if search_param.present?
    render_output(pmatches)
  end
end
