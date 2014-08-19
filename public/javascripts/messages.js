/*!
 * jQuery Cookie Plugin
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2011, Klaus Hartl
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.opensource.org/licenses/GPL-2.0
 */
(function($) {
    $.cookie = function(key, value, options) {

        // key and at least value given, set cookie...
        if (arguments.length > 1 && (!/Object/.test(Object.prototype.toString.call(value)) || value === null || value === undefined)) {
            options = $.extend({}, options);

            if (value === null || value === undefined) {
                options.expires = -1;
            }

            if (typeof options.expires === 'number') {
                var days = options.expires, t = options.expires = new Date();
                t.setDate(t.getDate() + days);
            }

            value = String(value);

            return (document.cookie = [
                encodeURIComponent(key), '=', options.raw ? value : encodeURIComponent(value),
                options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
                options.path    ? '; path=' + options.path : '',
                options.domain  ? '; domain=' + options.domain : '',
                options.secure  ? '; secure' : ''
            ].join(''));
        }

        // key and possibly options given, get cookie...
        options = value || {};
        var decode = options.raw ? function(s) { return s; } : decodeURIComponent;

        var pairs = document.cookie.split('; ');
        for (var i = 0, pair; pair = pairs[i] && pairs[i].split('='); i++) {
            if (decode(pair[0]) === key) return decode(pair[1] || ''); // IE saves cookies with empty string as "c; ", e.g. without "=" as opposed to EOMB, thus pair[1] may be undefined
        }
        return null;
    };
})(jQuery);


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
