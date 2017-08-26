class AddCollectionParticipantsService

  attr_reader :collection, :invitees, :participants_added, :participants_invited

  def initialize(collection, invitees)
    @collection = collection
    @invitees = invitees
    @participants_added = []
    @participants_invited = []
    @errors = []
  end

  def perform
    process_invitees
    unless (participants_added + participants_invited).present?
      check_for_bad_pseuds
    end
    @errors.empty?
  end

  def success_message
    [successful_additions, successful_invites].join(' ')
  end

  def error_message
    @errors.join(' ')
  end

  private

  def process_invitees
    participants = collection.collection_participants
    invited_pseuds.each do |pseud|
      participant = participants.find{ |p| p.pseud_id == pseud.id }
      if participant
        add_participant(participant)
      else
        invite_participant(pseud)
      end
    end
  end

  def add_participant(participant)
    if participant.is_none? && participant.approve_membership!
      participants_added << participant
    end
  end

  def invite_participant(pseud)
    participant = CollectionParticipant.new(
      collection: collection, 
      pseud: pseud, 
      participant_role: CollectionParticipant::MEMBER
    )
    if participant.save
      participants_invited << participant
    else
      @errors << "Could not invite #{pseud.name} to this collection."
    end
  end

  def successful_additions
    return unless participants_added.present?
    "Members added: " + participants_added.map{ |p| p.pseud.byline }.sort.join(', ')
  end

  def successful_invites
    return unless participants_invited.present?
    "New members invited: " + participants_invited.map{ |p| p.pseud.byline }.sort.join(', ')
  end

  def check_for_bad_pseuds
    return if (participants_added + participants_invited).present?
    if banned_pseuds.present?
      @errors << "#{banned_pseuds.to_sentence} is currently banned and cannot participate in challenges."
    else
      @errors << "We couldn't find anyone new by that name to add."
    end
  end

  def invited_pseuds
    parsed_pseuds[:pseuds]
  end

  def banned_pseuds
    parsed_pseuds[:banned_pseuds]
  end

  def parsed_pseuds
    @parsed_pseuds ||= Pseud.parse_bylines(invitees, assume_matching_login: true)
  end
end