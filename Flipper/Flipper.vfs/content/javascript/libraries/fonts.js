var fonts = (function() {

	var font_map = {
		"Arial":  "arialbd.ttf",
		"key1":  "font1.ttf",
		"key2":  "font2.ttf"
	};

	var fonts_module = {};

	(function initialize() {

		Object.keys(font_map).forEach(

			function(name) {

				document.styleSheets[0].insertRule(
					"@font-face {"
						+ "font-family: \"" + name + "\";"
						+ "src: url(\"../fonts/" + font_map[name] + "\");"
					+ "}"
					, 0
				);

				fonts_module[name] = name;
			}
		);

	}());

	console.log("fonts logic loaded");

	return fonts_module;

}());
