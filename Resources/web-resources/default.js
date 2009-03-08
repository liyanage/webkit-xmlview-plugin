
document.observe("xmlviewplugin:loaded", xmlviewpluginLoaded);

function xmlviewpluginLoaded() {
	$('body').observe('click', clickElement);
}

function clickElement(event) {
	var e = event.element();
	if (!e.hasClassName('mixed')) return;
	if (e.nodeName == 'SPAN') e = e.parentNode;
	toggleElementCollapse(e, event.altKey);
	event.stop();
}

function toggleElementCollapse(e, deep) {
	a = [e];
	if (deep) a = a.concat(e.select('div.element.mixed'));
	a.each(function (e) {
		e.childElements().find(function (x) {return x.match('.mixedcontent')}).toggle();
		e.childElements().findAll(function (x) {return x.match('span.tag')}).invoke('toggleClassName', 'collapsed');
	});
}
