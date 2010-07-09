<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output
	method="xml"
	version="1.0"
	encoding="utf-8"
	indent="no"
	doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
	doctype-public="-//W3C//DTD XHTML 1.1//EN"
	cdata-section-elements="script"
/>
<!--
	doctype-system="-//W3C//DTD HTML 4.01//EN"
	doctype-public="http://www.w3.org/TR/html4/strict.dtd"
-->
<xsl:param name="web_resource_base"/>
<xsl:param name="user_css"/>
<xsl:param name="user_js"/>
<xsl:param name="user_js_base64"/>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="/">
<html version="XHTML 1.1">
	<head>
		<xsl:comment>
			<xsl:value-of select="concat(system-property('xsl:version'), '/', system-property('xsl:vendor'), '/', system-property('xsl:vendor-url'))"/>
		</xsl:comment>
		<script type='text/javascript' src='{$web_resource_base}/prototype.js'/>
		<script type='text/javascript'>
			function xmlViewPluginSetup() {
				document.fire("xmlviewplugin:loaded");
			}
			document.observe("dom:loaded", xmlViewPluginSetup);
		</script>
		<script type='text/javascript' src="data:text/javascript;base64,{$user_js_base64}"/>
		<style type='text/css'><xsl:copy-of select="$user_css"/></style>
	</head>
	<body id='body'><xsl:apply-templates/></body>
	
</html>
</xsl:template>

</xsl:stylesheet>