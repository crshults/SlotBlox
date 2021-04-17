var loadingindicator = (function() {

	'use strict';

	var initialize = function () {

		document.styleSheets[0].insertRule(
			"@keyframes loading_indicator_gray {"
				+ "0%   {background-color: #606060;}"
				+ "10%  {background-color: #707070;}"
				+ "20%  {background-color: #808080;}"
				+ "30%  {background-color: #909090;}"
				+ "40%  {background-color: #A0A0A0;}"
				+ "50%  {background-color: #B0B0B0;}"
				+ "60%  {background-color: #C0C0C0;}"
				+ "70%  {background-color: #D0D0D0;}"
				+ "80%  {background-color: #B0B0B0;}"
				+ "90%  {background-color: #909090;}"
				+ "100% {background-color: #707070;}"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			"@keyframes loading_indicator_red {"
				+ "0%   {background-color: #ff8000;}"
				+ "10%  {background-color: #ff6000;}"
				+ "20%  {background-color: #ff3000;}"
				+ "30%  {background-color: #ff2000;}"
				+ "40%  {background-color: #ff1000;}"
				+ "50%  {background-color: #ff0000;}"
				+ "60%  {background-color: #ff0000;}"
				+ "70%  {background-color: #ff1000;}"
				+ "80%  {background-color: #ff2000;}"
				+ "90%  {background-color: #ff3000;}"
				+ "100% {background-color: #ff4000;}"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			"@keyframes loading_indicator_blue {"
				+ "0%   {background-color: #0080ff;}"
				+ "10%  {background-color: #0060ff;}"
				+ "20%  {background-color: #0030ff;}"
				+ "30%  {background-color: #0020ff;}"
				+ "40%  {background-color: #0010ff;}"
				+ "50%  {background-color: #0000ff;}"
				+ "60%  {background-color: #0000ff;}"
				+ "70%  {background-color: #0010ff;}"
				+ "80%  {background-color: #0020ff;}"
				+ "90%  {background-color: #0030ff;}"
				+ "100% {background-color: #0040ff;}"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			"@keyframes loading_indicator_green {"
				+ "0%   {background-color: #80ff80;}"
				+ "10%  {background-color: #60ff60;}"
				+ "20%  {background-color: #30ff30;}"
				+ "30%  {background-color: #20ff20;}"
				+ "40%  {background-color: #10ff10;}"
				+ "50%  {background-color: #00ff00;}"
				+ "60%  {background-color: #00ff00;}"
				+ "70%  {background-color: #10ff10;}"
				+ "80%  {background-color: #20ff20;}"
				+ "90%  {background-color: #30ff30;}"
				+ "100% {background-color: #40ff40;}"
			+ "}"
			, 0
		);

		var newDiv = document.createElement("div");
		newDiv.setAttribute("id", "loadingindicator_container");
		newDiv.style.position        = "absolute";
		newDiv.style.backgroundColor = "transparent";
		//newDiv.style.overflow        = "hidden";
		newDiv.style.left            = "45%";
		newDiv.style.top             = "45%";
		newDiv.style.width           = "10%";
		newDiv.style.height          = "10%";
		document.getElementById("screen").appendChild(newDiv);

		for (var i = 1; i <= 9; ++i) {

			var newDiv = document.createElement("div");
			newDiv.setAttribute("id", "loadingindicator_part_" + i);
			newDiv.style.position                = "absolute";
			newDiv.style.backgroundColor         = "transparent";
			newDiv.style.left                    = i * 11 - 10 + "%";
			newDiv.style.top                     = "0%";
			newDiv.style.width                   = "10%";
			newDiv.style.height                  = "100%";
			newDiv.style.animationDelay          = i * 100 + "ms";
			newDiv.style.animationDirection      = "normal";
			newDiv.style.animationDuration       = "3000ms";
			newDiv.style.animationFillMode       = "forwards";
			newDiv.style.animationIterationCount = "infinite";
			newDiv.style.animationName           = "loading_indicator_blue";
			newDiv.style.animationPlayState      = "running";
			newDiv.style.animationTimingFunction = "linear";
			document
				.getElementById("loadingindicator_container")
				.appendChild(newDiv);
		}
	}

	window.addEventListener('load', initialize);

	var loadingindicator_module = {};

	loadingindicator_module.red = function() {

		for (var i = 1; i <= 9; ++i) {

			document
				.getElementById("loadingindicator_part_" + i)
				.style
				.animationName = "loading_indicator_red";
		}
	};

	loadingindicator_module.blue = function() {

		for (var i = 1; i <= 9; ++i) {

			document
				.getElementById("loadingindicator_part_" + i)
				.style
				.animationName = "loading_indicator_blue";
		}
	};

	loadingindicator_module.green = function() {

		for (var i = 1; i <= 9; ++i) {

			document
				.getElementById("loadingindicator_part_" + i)
				.style
				.animationName = "loading_indicator_green";
		}
	};

	loadingindicator_module.gray = function() {

		for (var i = 1; i <= 9; ++i) {

			document
				.getElementById("loadingindicator_part_" + i)
				.style
				.animationName = "loading_indicator_gray";
		}
	};

	return loadingindicator_module;

}());
