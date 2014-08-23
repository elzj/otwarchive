var UserChannel = (function() {

    var dispatcher, channelName, cookieName = 'user_channel_key';

    function init(globalDispatcher) {
        dispatcher = globalDispatcher;
        dispatcher.on_open = connect;
        channelName = $j.cookie(cookieName)
    }

    function connect() {
       if (channelName) {
           getChannel(channelName);
       } else {
           getKey();
       }
    }

    function getKey() {
        dispatcher.bind('user.key', function (key) {
            $j.cookie(cookieName, key, { expires: 30 });
            getChannel(key);
        });

        dispatcher.trigger('user.get_channel_key', {});
    }

    function getChannel(key) {
        var channel = dispatcher.subscribe_private(key);

        channel.on_success = function () {
          console.log("yay, you're connected to this channel");
          channel.bind('new', function(message) {
            console.log('you have mail!');
            var oldCount = Number($j('span#messagecount').html());
            $j('span#messagecount').html(oldCount + 1);
          });
        };

        channel.on_failure = function (reason) {
            $j.removeCookie(cookieName);
            console.log("Authorization failed because " + reason.message);
        };
    }

    return { init: init };

})();

$j(document).on('ready', function() {
    var globalDispatcher = new WebSocketRails('localhost:3000/websocket');
    UserChannel.init(globalDispatcher);
});
