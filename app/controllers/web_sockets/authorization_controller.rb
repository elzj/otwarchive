class WebSockets::AuthorizationController < WebsocketRails::BaseController
  def get_channel_key
    if current_user
      key = current_user.channel_key
      WebsocketRails[key].make_private
      send_message :key, key, :namespace => :user
    else
      send_message :key, nil, :namespace => :user
    end
  end

  def authorize_user_channel
    if current_user && current_user.channel_key == message[:channel]
      accept_channel(current_user)
    else
      deny_channel nil
    end
  end

end
