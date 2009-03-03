
document.observe("xmlviewplugin:loaded", xmlviewpluginLoaded);

function xmlviewpluginLoaded() {
	$('body').observe('click', clickElement);
}

function clickElement(event) {
	var e = event.element();
	if (!e.hasClassName('mixed')) return;
	if (e.nodeName == 'SPAN') e = e.parentNode;
	e.down('.mixedcontent').toggle();
	e.select('span.tag').invoke('toggleClassName', 'collapsed');
}