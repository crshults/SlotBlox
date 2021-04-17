var screencontent = (function() {

	'use strict';

	var screen_element;
	var front_element;
	var back_element;

	var initialize = function() {

		screen_element = document.getElementById("screen");
		front_element = null;
		back_element = null;

		document.styleSheets[0].insertRule(
			".screen_showing_front_side {"
				+ "transform: rotateY(0deg);"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".screen_flipping_to_back_side {"
				+ "animation-name: screen_flipping_to_back_side;"
				+ "animation-iteration-count: 1;"
				+ "animation-fill-mode: forwards;"
				+ "animation-timing-function: ease-in-out;"
				+ "animation-duration: 500ms;"
				+ "animation-direction: forwards;"
				+ "animation-state: running;"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			"@keyframes screen_flipping_to_back_side {"
				+ "from {"
				+ "transform: rotateY(0deg);"
				+ "}"
				+ "to {"
				+ "transform: rotateY(180deg);"
				+ "}"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".screen_showing_back_side {"
				+ "transform: rotateY(180deg);"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".screen_flipping_to_front_side {"
				+ "animation-name: screen_flipping_to_front_side;"
				+ "animation-iteration-count: 1;"
				+ "animation-fill-mode: forwards;"
				+ "animation-timing-function: ease-in-out;"
				+ "animation-duration: 500ms;"
				+ "animation-direction: forwards;"
				+ "animation-state: running;"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			"@keyframes screen_flipping_to_front_side {"
				+ "from {"
				+ "transform: rotateY(180deg);"
				+ "}"
				+ "to {"
				+ "transform: rotateY(0deg);"
				+ "}"
			+ "}"
			, 0
		);

		screen_element.addEventListener(
			"animationend",
			function() {

				if (screen_element.classList.contains(
					"screen_flipping_to_back_side"
					)
				) {

					screen_element.classList.replace(
						"screen_flipping_to_back_side",
						"screen_showing_back_side"
					);

					try {

						back_element.focus();

					} catch(_) {}

				} else if (screen_element.classList.contains(
					"screen_flipping_to_front_side"
					)
				) {

					screen_element.classList.replace(
						"screen_flipping_to_front_side",
						"screen_showing_front_side"
					);

					try {

						front_element.focus();

					} catch(_) {}

				}
			}
		);

		screen_element.classList.add("screen_showing_front_side");
	};

	window.addEventListener('load', initialize);

	var screencontent_module = {};

	screencontent_module.showFront = function(address) {

		if (front_element === null) {

			front_element = document.createElement("iframe");
			front_element.setAttribute("id", "front");
			front_element.setAttribute("src", address);
			front_element.style.position           = "absolute";
			front_element.style.backgroundColor    = "black";
			front_element.style.left               = "0%";
			front_element.style.top                = "0%";
			front_element.style.width              = "100%";
			front_element.style.height             = "100%";
			front_element.style.backfaceVisibility = "hidden";
			screen_element.insertBefore(front_element, back_element);

			if (screen_element.classList.contains(
				"screen_showing_front_side"
				)
			) {

				front_element.contentWindow.focus();
			}
		}
	};

	screencontent_module.hideFront = function() {

		front_element.parentNode.removeChild(front_element);
		front_element = null;
	};

	screencontent_module.showBack = function(address) {

		if (back_element === null) {

			back_element = document.createElement("iframe");
			back_element.setAttribute("id", "back");
			back_element.setAttribute("src", address);
			back_element.style.position           = "absolute";
			back_element.style.backgroundColor    = "black";
			back_element.style.left               = "0%";
			back_element.style.top                = "0%";
			back_element.style.width              = "100%";
			back_element.style.height             = "100%";
			back_element.style.backfaceVisibility = "hidden";
			back_element.style.transform          = "rotateY(180deg)";
			screen_element.appendChild(back_element);

			if (screen_element.classList.contains(
				"screen_showing_back_side"
				)
			) {

				back_element.focus();
			}
		}
	};

	screencontent_module.hideBack = function() {

		back_element.parentNode.removeChild(back_element);
		back_element = null;
	};


	screencontent_module.flipSides = function() {

		if (screen_element.classList.contains(
			"screen_showing_back_side"
			)
		) {

			screen_element.classList.replace(
				"screen_showing_back_side",
				"screen_flipping_to_front_side"
			);
		} else if (screen_element.classList.contains(
			"screen_showing_front_side"
			)
		) {

			screen_element.classList.replace(
				"screen_showing_front_side",
				"screen_flipping_to_back_side"
			);
		}
	};

	return screencontent_module;

}());
