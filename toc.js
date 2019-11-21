/*
 * Dynamic Table of Contents script
 * by Matt Whitlock <http://www.whitsoftdev.com/>
 */

function createLink(href, innerHTML) {
	var a = document.createElement("a");
	a.setAttribute("href", href);
	a.innerHTML = innerHTML;
	return a;
}

function generateTOC(toc) {
	var i2 = 0;
	toc = toc.appendChild(document.createElement("a"));
	for (var i = 0; i < document.body.childNodes.length; ++i) {
		var node = document.body.childNodes[i];
		var ID = node.id
		if (ID != "header1") { continue; }
		node = node.childNodes[0]
		ID = node.id
		if (ID == "ch1") {
			++i2;
			var section = i2;
			// node.insertBefore(document.createTextNode(section + "12222. "), node.firstChild);
			node.id = "test" + section;
			toc.appendChild(h2item = document.createElement("a")).appendChild(createLink("#test" + section, node.innerHTML));
			toc.appendChild(document.createElement("br"));
		}
	}

	var type = window.location.hash.substr(1);
	if (type) {
		setTimeout(function() {
    		window.location.hash = "";
    		window.location.hash = type;
		}, 1);
	}
}