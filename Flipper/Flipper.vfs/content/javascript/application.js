(function () {

	'use strict';

	var message_handler = function(original_message) {

		var message = dictToObject(original_message);

		switch (message.summary) {

			case "websocket connection unavailable":

				loadingindicator.blue();

				break;

			case "websocket connection available":

				loadingindicator.green();

				websocket.send(
					"sender flipper_frontend "
					+ "receiver flipper "
					+ "summary {user interface available} "
					+ "details {}"
					+ " "
				);

				break;

			case "websocket connection dead":

				loadingindicator.gray();

				break;

			case "load front content":

				screencontent.showFront(message.details.address);
				break;

			case "hide front content":

				screencontent.hideFront();
				break;

			case "load back content":

				screencontent.showBack(message.details.address);
				break;

			case "hide back content":

				screencontent.hideBack();
				break;

			case "key pressed":

				switch (message.details.name) {

					case "DOM_VK_F2":

						screencontent.flipSides();
						break;
				}

				break;

			case "set credit meter":

				meters.credits.setValue(message.details.value / 100);
				break;

			case "clear credit meter":

				meters.credits.clear();
				break;

			default:

				break;
		}
	};

	var initialize = function () {

		websocket.registerCallback(message_handler);
		keyboard.registerCallback(message_handler);
		text.containerContentFontColor("name", "Flipper", fonts.Arial, "white");
		text.forceResize();
	};

	window.addEventListener('message', function(event) {

		message_handler(
			"sender flipper_frontend "
			+ "receiver flipper_frontend "
			+ "summary {" + event.data.summary + "} "
			+ "details {name " + event.data.details + " {}}"
			+ " "
		);
	});

	window.addEventListener('load', initialize);

}());
