var websocket = (function() {

	'use strict';

	var socket;
	var callback;
	var was_connected;

	var establishConnection = function() {

		socket = new WebSocket("ws://" + location.host);

		socket.onopen = function(){

			was_connected = true;

			try {

				callback(
					"sender websocket.js "
					+ "receiver ui "
					+ "summary {websocket connection available} "
					+ "details {}"
				);

			} catch(_) {}
		};

		socket.onmessage = function(event){

			try {

				callback(event.data);

			} catch(_) {}
		};

		socket.onclose = function(event){

			if (was_connected) {

				// It's dead, Jim.

				try {

					callback(
						"sender websocket.js "
						+ "receiver ui "
						+ "summary {websocket connection dead} "
						+ "details {}"
					);

				} catch(_) {}

				return;
			}

			window.setTimeout(establishConnection, 1);

			try {

				callback(
					"sender websocket.js "
					+ "receiver ui "
					+ "summary {websocket connection unavailable} "
					+ "details {}"
				);

			} catch(_) {}
		};

		socket.onerror = function(event){
		};

	};

	var websocket_module = {};

	websocket_module.send = function(message) {

		if (socket.readyState === 1) {
			socket.send(message);
		}
	};

	websocket_module.registerCallback = function(_callback) {

		callback = _callback;

		callback(
			"sender websocket.js "
			+ "receiver ui "
			+ "summary {websocket connection unavailable} "
			+ "details {}"
		);

		was_connected = false;
		establishConnection();
	};

	return websocket_module;

}());
