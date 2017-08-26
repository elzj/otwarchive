class CollectionParticipantsController < ApplicationController
  before_action :load_collection
  before_action :load_participant_and_collection, only: [:update, :destroy]
  before_action :allowed_to_promote, only: [:update]
  before_action :allowed_to_destroy, only: [:destroy]
  before_action :has_other_owners, only: [:update, :destroy]
  before_action :collection_maintainers_only, only: [:index, :add, :update]
  before_action :users_only, only: [:join]

  cache_sweeper :collection_sweeper

  def owners_required
    flash[:error] = t('collection_participants.owners_required', default: "You can't remove the only owner!")
    redirect_to collection_participants_path(@collection)
    false
  end

  def no_participant
    flash[:error] = t('no_participant', default: "Which participant did you want to work with?")
    redirect_to root_path
  end

  def load_participant_and_collection
    if params[:collection_participant]
      @participant = CollectionParticipant.find_by(id: collection_participant_params[:id])
      @new_role = collection_participant_params[:participant_role]
    else
      @participant = CollectionParticipant.find_by(id: params[:id])
    end

    no_participant and return unless @participant
    @collection = @participant.collection
  end

  def allowed_to_promote
    @participant.user_allowed_to_promote?(current_user, @new_role) || not_allowed(@collection)
  end

  def allowed_to_destroy
    @participant.user_allowed_to_destroy?(current_user) || not_allowed(@collection)
  end

  def has_other_owners
    !@participant.is_owner? || (@collection.owners != [@participant.pseud]) || owners_required
  end

  ## ACTIONS

  def join
    service = NewCollectionParticipantService.new(@collection, current_user)
    if service.perform
      flash[:notice] = service.success_message
    else
      flash[:error] = service.error_message
    end
    redirect_to(request.env["HTTP_REFERER"] || root_path)
  end

  def index
    @collection_participants = @collection.collection_participants.reject {|p| p.pseud.nil?}.sort_by {|participant| participant.pseud.name.downcase }
  end

  def update
    if @participant.update_attributes(collection_participant_params)
      flash[:notice] = t('collection_participants.update_success', default: "Updated %{participant}.", participant: @participant.pseud.name)
    else
      flash[:error] = t('collection_participants.update_failure', default: "Couldn't update %{participant}.", participant: @participant.pseud.name)
    end
    redirect_to collection_participants_path(@collection)
  end

  def destroy
    @participant.destroy
    flash[:notice] = t('collection_participants.destroy', default: "Removed %{participant} from collection.", participant: @participant.pseud.name)
    redirect_to(request.env["HTTP_REFERER"] || root_path)
  end

  def add
    service = AddCollectionParticipantsService.new(@collection, params[:participants_to_invite])
    if service.perform
      flash[:notice] = service.success_message
    else
      flash[:error] = service.error_message
    end
    redirect_to collection_participants_path(@collection)
  end

  private

  def collection_participant_params
    params.require(:collection_participant).permit(
      :id, :participant_role, :collection_id
    )
  end

end
