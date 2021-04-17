(function() {

	'use strict';

	var aspect_ratio = {
		width: 4,
		height: 3
	};

	function width_given_ratio(aspect_ratio) {
		return parseInt((window.innerWidth/window.innerHeight > (aspect_ratio.width/aspect_ratio.height)) ? window.innerHeight*(aspect_ratio.width/aspect_ratio.height) : window.innerWidth);
	}

	function height_given_ratio(aspect_ratio) {
		return parseInt((window.innerWidth/window.innerHeight > (aspect_ratio.width/aspect_ratio.height)) ? window.innerHeight : window.innerWidth/(aspect_ratio.width/aspect_ratio.height));
	}

	function set_screen_size_and_position() {
		document.getElementById("screen").style.width = width_given_ratio(aspect_ratio) + "px";
		document.getElementById("screen").style.height = height_given_ratio(aspect_ratio) + "px";
		document.getElementById("screen").style.left = parseInt(window.innerWidth-width_given_ratio(aspect_ratio))/2 + "px";
		document.getElementById("screen").style.top = parseInt(window.innerHeight-height_given_ratio(aspect_ratio))/2 + "px";
	};

	window.addEventListener('resize', set_screen_size_and_position);
	window.addEventListener('load', set_screen_size_and_position);

}());
