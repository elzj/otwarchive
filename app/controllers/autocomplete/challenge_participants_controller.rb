# frozen_string_literal: true

class Autocomplete::ChallengeParticipantsController < Autocomplete::BaseController
  # people signed up for a challenge
  def index
    search_param = params[:term]
    collection_id = params[:collection_id]
    render_output(
      Pseud.limit(10)
           .order(:name)
           .joins(:challenge_signups)
           .where(
             [
               "pseuds.name LIKE ? AND challenge_signups.collection_id = ?",
               '%' + search_param + '%',
               collection_id
             ]
           ).map(&:byline)
    )
  end
end
