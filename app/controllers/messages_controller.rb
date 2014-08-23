class MessagesController < ApplicationController
  before_filter :users_only
  before_filter :load_user
  before_filter :check_ownership

  def index
    @messages = Message.for_user(@user)
    if params[:status] == 'unread'
      @messages = @messages.unread
    end
    @messages = @messages.order('created_at DESC').page(params[:page])
  end

  def show
    @message = Message.for_user(@user).find(params[:id])
  end

  def new
    @message = Message.new
  end

  def edit
    @message = Message.find(params[:id])
  end

  def create
    @message = Message.new
  end

  def update
    @message = Message.find(params[:id])
  end

  def destroy
    @message = Message.find(params[:id])
  end

  protected

  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end

end
