class NewCollectionParticipantService

  attr_accessor :participant
  attr_reader :collection, :user, :errors, :success_message

  def initialize(collection, user)
    @collection = collection
    @user = user
    @errors = []
    @success_message = nil
  end

  def perform
    @participant = CollectionParticipant.in_collection(collection).
                                        for_user(user).
                                        first
    if participant.present?
      approve_membership
    else
      join_collection
    end
    errors.empty?
  end

  def error_message
    @errors.join(', ')
  end

  private

  def approve_membership
    if participant.is_invited?
      participant.approve_membership!
      @success_message = "You are now a member of #{collection.title}."
    else
      @errors << "You have already joined (or applied to) this collection."
    end
  end

  def join_collection
    participant = CollectionParticipant.new(
      collection: collection,
      pseud: user.default_pseud,
      participant_role: CollectionParticipant::NONE
    )
    if participant.save!
      @success_message = "You have applied to join #{collection.title}."
    else
      @errors += participant.full_messages
    end
  end
end