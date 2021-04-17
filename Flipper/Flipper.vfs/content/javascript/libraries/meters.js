'use strict';

var meters = (function() {

	var meters_module = {};

	var initialize = function() {

		console.log("meters.initialize");

		document.styleSheets[0].insertRule(
			".metal {"
				+ "background: linear-gradient("
					+ "to right,"
					+ "#5b5b5b 0%,"
					+ "#c9c9c9 15%,"
					+ "#5b5b5b 29%,"
					+ "#5b5b5b 39%,"
					+ "#ffffff 44%,"
					+ "#5b5b5b 49%,"
					+ "#5b5b5b 65%,"
					+ "#ffffff 68%,"
					+ "#5b5b5b 72%,"
					+ "#ffffff 77%,"
					+ "#ffffff 80%,"
					+ "#bfbfbf 83%,"
					+ "#ffffff 85%,"
					+ "#939393 89%,"
					+ "#ffffff 91%,"
					+ "#5b5b5b 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".wood {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#7a4900 0%,"
					+ "#d6a700 8%,"
					+ "#7a4900 11%,"
					+ "#d6a700 20%,"
					+ "#7a4900 28%,"
					+ "#141100 30%,"
					+ "#7a4900 32%,"
					+ "#d6a700 38%,"
					+ "#7a4900 44%,"
					+ "#141100 47%,"
					+ "#7a4900 49%,"
					+ "#d6a700 52%,"
					+ "#7a4900 62%,"
					+ "#141100 64%,"
					+ "#7a4900 66%,"
					+ "#d6a700 73%,"
					+ "#7a4900 82%,"
					+ "#141100 84%,"
					+ "#7a4900 86%,"
					+ "#d6a700 95%,"
					+ "#7a4900 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".marble {"
				+ "background: linear-gradient("
					+ "135deg,"
					+ "#ffffff 0%,"
					+ "#000000 1%,"
					+ "#ffffff 2%,"
					+ "#898989 10%,"
					+ "#ffffff 13%,"
					+ "#ffffff 22%,"
					+ "#000000 23%,"
					+ "#ffffff 25%,"
					+ "#898989 34%,"
					+ "#ffffff 43%,"
					+ "#000000 44%,"
					+ "#ffffff 46%,"
					+ "#ffffff 57%,"
					+ "#898989 62%,"
					+ "#ffffff 65%,"
					+ "#000000 70%,"
					+ "#ffffff 72%,"
					+ "#898989 80%,"
					+ "#ffffff 86%,"
					+ "#000000 89%,"
					+ "#ffffff 91%,"
					+ "#898989 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".citrus {"
				+ "background: linear-gradient("
					+ "to right,"
					+ "#faff00 0%,"
					+ "#10ff00 7%,"
					+ "#faff00 14%,"
					+ "#10ff00 22%,"
					+ "#faff00 30%,"
					+ "#10ff00 36%,"
					+ "#faff00 45%,"
					+ "#10ff00 51%,"
					+ "#faff00 60%,"
					+ "#10ff00 67%,"
					+ "#faff00 75%,"
					+ "#10ff00 83%,"
					+ "#faff00 91%,"
					+ "#10ff00 98%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_red {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#660000 0%,"
					+ "#c60000 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_orange {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#4f2600 0%,"
					+ "#d37000 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_green {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#003300 0%,"
					+ "#029300 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_blue {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#00062b 0%,"
					+ "#000489 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_yellow {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#515100 0%,"
					+ "#faff00 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_purple {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#41004f 0%,"
					+ "#c700ff 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_aqua {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#002d2d 0%,"
					+ "#00fffa 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_pink {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#680068 0%,"
					+ "#ff00d8 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_gray {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#6d6264 0%,"
					+ "#ffffff 100%"
				+ ");"
			+ "}"
			, 0
		);

		document.styleSheets[0].insertRule(
			".meter_face_brown {"
				+ "background: linear-gradient("
					+ "to bottom,"
					+ "#141100 0%,"
					+ "#7a4900 100%"
				+ ");"
			+ "}"
			, 0
		);

		var meters_elements = [].slice.call(document.getElementsByClassName("meter"));

		for (var i = 0; i < meters_elements.length; ++i) {

			var meter_width = meters_elements[i].clientWidth;
			var meter_height = meters_elements[i].clientHeight;

			meters_elements[i].style.borderRadius = (meter_height/meter_width) * 5 + "%/5%";
			meters_elements[i].className = "meter metal";

			var face = document.createElement("div");
			face.setAttribute("id", meters_elements[i].id + "_face");
			face.className = "meter_face_blue";
			face.style.backgroundSize = "cover";
			face.style.position = "absolute";
			face.style.left = 7.5 * meters_elements[i].clientHeight / meters_elements[i].clientWidth + "%";
			face.style.top = "7.5%";
			face.style.width = 100.0 - (2.0 * parseFloat(face.style.left)) + "%";
			face.style.height = "85%";
			meters_elements[i].appendChild(face);
			var content_width = face.clientWidth;
			var content_height = face.clientHeight;

			face.style.borderRadius = (content_height/content_width) * 5 + "%/5%";

			var newDiv = document.createElement("div");
			newDiv.setAttribute("id", meters_elements[i].id + "_label");
			newDiv.style.backgroundColor = "transparent";
			newDiv.style.position = "absolute";
			newDiv.style.left = 5.0 * face.clientHeight / face.clientWidth + "%";
			newDiv.style.top = "5%";
			newDiv.style.width = 100.0 - (2.0 * parseFloat(newDiv.style.left)) + "%";
			newDiv.style.height = "30%";
			face.appendChild(newDiv);

			// Name should come from the name of the element
			text.containerContentFontColor(newDiv.id, meters_elements[i].id, "key2", "#04caf7", "left");

			newDiv = document.createElement("div");
			newDiv.setAttribute("id", meters_elements[i].id + "_content");
			newDiv.style.backgroundColor = "transparent";
			newDiv.style.position = "absolute";
			newDiv.style.left = 5.0 * face.clientHeight / face.clientWidth + "%";
			newDiv.style.top = "45%";
			newDiv.style.width = 100.0 - (2.0 * parseFloat(newDiv.style.left)) + "%";
			newDiv.style.height = "50%";
			face.appendChild(newDiv);

			// Don't give any content yet
			text.containerContentFontColor(newDiv.id, "", "key2", "#04caf7", "right");
			text.forceResize();
		}

		// could also provide different versions for cents, dollars, raw numbers, etc.
		// starts to lose precision at: 9999999999999.99
		meters_elements.forEach(
			function(m) {
				meters_module[m.id] = {};
				meters_module[m.id].setValue = function(newValue) {
					text.containerContentFontColor(m.id + "_content", "$" + newValue.toMoney(), "key2", "#04caf7", "right");
					text.forceResize();
				};
				meters_module[m.id].clear = function() {
					text.containerContentFontColor(m.id + "_content", "", "key2", "#04caf7", "right");
					text.forceResize();
				};
			}
		);
	};

	window.addEventListener('load', initialize);

	return meters_module;

}());
