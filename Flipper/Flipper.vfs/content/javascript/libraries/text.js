var text = (function() {

	var resizeTextBoxes = function() {

		var t0 = performance.now();

		var textBoxes = document.getElementsByClassName("text");

		for (var i = 0; i < textBoxes.length; ++i) {

			// hide the contents while we resize
			textBoxes[i].style.visibility = "hidden";

			// Set the font size to a very large size
			textBoxes[i].style.fontSize = "200px";

			// Determine how many lines of content there are
			var contentNumberOfLines =
				textBoxes[i].clientHeight /
				parseInt(textBoxes[i].style.fontSize);

			// calculate the string aspect ratio
			var contentAspectRatio =
				textBoxes[i].clientWidth /
				textBoxes[i].clientHeight;

			// calculate the container aspect ratio
			var containerAspectRatio =
				textBoxes[i].parentElement.clientWidth /
				textBoxes[i].parentElement.clientHeight;

			// determine if container makes the contents height or width bound
			if (containerAspectRatio > contentAspectRatio) {

				// Height bound
				textBoxes[i].style.fontSize =
					textBoxes[i].parentElement.clientHeight /
					contentNumberOfLines +
					"px";

			} else {

				// Width bound
				textBoxes[i].style.fontSize =
					textBoxes[i].parentElement.clientWidth /
					contentAspectRatio /
					contentNumberOfLines +
					"px";

			}

			// show the newly resized contents
			// use inherit in case the parent is currently hidden
			textBoxes[i].style.visibility = "inherit";
		}

		var t1 = performance.now();

		console.log("resizeTextBoxes took " + (t1 - t0) + " milliseconds.")
	};

	(function initialize() {

		window.addEventListener('resize', resizeTextBoxes);
		//window.addEventListener('load', resizeTextBoxes);

	}());

	var text_module = {};

	text_module.containerContentFontColor = function(container, content, font, color, alignment) {

		var container_element = document.getElementById(container);

		if (container_element.hasChildNodes()) {

			var content_element = document.getElementById(container + "_text_content");

			content_element.innerHTML = content;
			content_element.style.color = color;
			try {
				content_element.style.fontFamily = font;
			} catch(_) {}

		} else {

			container_element.style.display = "flex";
			container_element.style.flexDirection = "column";
			container_element.style.justifyContent = "center";
			container_element.style.alignContent = "flex-start";
			container_element.style.alignItems = alignment || "center";
			container_element.style.overflow = "hidden";

			var newDiv = document.createElement("div");
			newDiv.setAttribute("id", container + "_text_content");
			newDiv.setAttribute("class", "text");
			newDiv.style.textAlign = "center";
			newDiv.style.whiteSpace = "pre";
			newDiv.style.backgroundColor = "transparent";
			newDiv.style.color = color;
			newDiv.style.lineHeight = "100%";
			newDiv.style.fontSize = "1px";
			newDiv.innerHTML = content;
			try {
				newDiv.style.fontFamily = font;
			} catch(_) {}
			container_element.appendChild(newDiv);

		}

		// Not consistent on the resizing when changing fonts
		/*
		setTimeout(
			resizeTextBoxes, 100
		);
		*/

	};

	text_module.forceResize = function() {

		resizeTextBoxes();
	};

	console.log("text logic loaded");

	return text_module;

}());

//text.containerContentFontColor("box", "BUTTON<br />TEXT", fonts.key2, "white");
