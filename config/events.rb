WebsocketRails::EventMap.describe do
  namespace :user do
    subscribe :get_channel_key, 'web_sockets/authorization#get_channel_key'
  end

  namespace :websocket_rails do
    subscribe :subscribe_private, 'web_sockets/authorization#authorize_user_channel'
  end
end
