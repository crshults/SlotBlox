function dictToObject (dict) {

	var input = dictToArray(dict);

	var output = {};

	var k, v;
	for (k = 0, v = 1; v < input.length; k+=2, v+=2) {
		if (input[v].includes('{')) {
			output[input[k]] = dictToObject(input[v]);
		} else {
			output[input[k]] = input[v];
		}
	}

	return output;

}

function dictToArray(input) {

	var output = [];
	var current = "";
	var depth = 0;

	for (var i = 0; i < input.length; ++i) {

		switch (input[i]) {

			case '{':
				if (depth > 0) {
					current += input[i];
				}
				++depth;
				break;

			case '}':
				--depth;
				if (depth > 0) {
					current += input[i];
				} else if (depth === 0) {
					output.push(current);
					current = "";
				}
				break;

			case ' ':
				if (current && depth === 0) {
					output.push(current);
					current = "";
				} else if (depth > 0) {
					current += input[i];
				}
				break;

			default:
				current += input[i];
				break;

		}

	}

	if (current) {
		output.push(current);
	}

	return output;

}
