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
		<script type='text/javascript'>//__XML_VIEW_PLUGIN_USER_JS_START_LINE__
<xsl:copy-of select="$user_js"/></script>
		<style type='text/css'>
			<xsl:copy-of select="$user_css"/>
		</style>
	</head>
	<body id='body'><xsl:apply-templates/></body>
	
</html>
</xsl:template>


<xsl:template match="comment()">
	<div class='comment'>&lt;!--<xsl:value-of select="."/>--></div>
</xsl:template>

<xsl:template match="processing-instruction()">
	<div class='xmlpi'>&lt;?<xsl:value-of select="name()"/><xsl:if test="string-length(.) > 0"><xsl:text> </xsl:text><xsl:value-of select="."/></xsl:if>?></div>
</xsl:template>

<xsl:template match="text()">
	<span class='text'><xsl:copy/></span>
</xsl:template>


<!-- elements with mixed content -->
<xsl:template match="*[*|comment()|processing-instruction()]">
	<xsl:variable name="lname" select="concat('name_', local-name())" />
	<div class='element mixed {$lname}'>
	<span class='tag open mixed {$lname}'>&lt;<xsl:value-of select="name()"/><span class='attributes_and_namespaces'><xsl:call-template name='namespaces'/><xsl:apply-templates select="@*"/></span>></span>
	<div class='mixedcontent'>
		<xsl:apply-templates/>
	</div>
	<span class='tag close mixed {$lname}'>&lt;/<xsl:value-of select="name()"/>></span>
	</div>
</xsl:template>


<!-- elements without mixed content -->
<xsl:template match="*">
	<xsl:variable name="lname" select="concat('name_', local-name())" />
	<div class='element nomixed {$lname}'>
	<span class='tag open nomixed {$lname}'>&lt;<xsl:value-of select="name()"/><span class='attributes_and_namespaces'><xsl:call-template name='namespaces'/><xsl:apply-templates select="@*"/></span>></span><xsl:apply-templates/><span class='tag close nomixed {$lname}'>&lt;/<xsl:value-of select="name()"/>></span>
	</div>
</xsl:template>


<!-- empty elements -->
<xsl:template match="*[not(node())]">
	<xsl:variable name="lname" select="concat('name_', local-name())" />
	<div class='element selfclosed {$lname}'>
	<span class='tag selfclosed {$lname}'>&lt;<xsl:value-of select="name()"/><span class='attributes_and_namespaces'><xsl:call-template name='namespaces'/><xsl:apply-templates select="@*"/></span>/></span>
	</div>
</xsl:template>


<xsl:template match="@*">
	<xsl:text> </xsl:text><span class='attribute name'><xsl:value-of select="name()"/></span>=<xsl:apply-templates select="." mode="attrvalue"/>
</xsl:template>


<!-- Try to emit well-formed markup for all single/double quote combinations in attribute values -->
<xsl:template match="@*[not(contains(., '&quot;'))]" mode='attrvalue'>"<span class='attribute value'><xsl:value-of select="."/></span>"</xsl:template>
<xsl:template match='@*[not(contains(., "&apos;"))]' mode='attrvalue'>'<span class='attribute value'><xsl:value-of select="."/></span>'</xsl:template>
<xsl:template match='@*[contains(., "&apos;") and contains(., &apos;"&apos;)]' mode='attrvalue'>"<span class='attribute value'>
    <xsl:call-template name="replaceCharsInString">
      <xsl:with-param name="stringIn" select="string(.)"/>
      <xsl:with-param name="charsIn" select="'&quot;'"/>
      <xsl:with-param name="charsOut" select="'&amp;quot;'"/>
    </xsl:call-template>
</span>"</xsl:template>


<!-- Emit namespace declarations -->
<xsl:template name="namespaces">
	<xsl:for-each select="@*|.">
		<xsl:variable name="my_ns" select="namespace-uri()"/>
		<!-- Emit a namespace declaration if this element or attribute has a namespace and no ancestor already defines it.
		     Currently this produces redundant declarations for namespaces used only on attributes. -->
		<xsl:if test="$my_ns and not(ancestor::*[namespace-uri() = $my_ns])">
			<xsl:variable name="prefix" select="substring-before(name(), local-name())"/>
			<span class='namespace'> xmlns<xsl:if test="$prefix">:<xsl:value-of select="substring-before($prefix, ':')"/></xsl:if>='<xsl:value-of select="namespace-uri()"/>'</span>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!-- string search/replace used in the attribute quote templates above. From http://www.dpawson.co.uk/xsl/sect2/replace.html -->
<xsl:template name="replaceCharsInString">
  <xsl:param name="stringIn"/>
  <xsl:param name="charsIn"/>
  <xsl:param name="charsOut"/>
  <xsl:choose>
    <xsl:when test="contains($stringIn,$charsIn)">
      <xsl:value-of select="concat(substring-before($stringIn,$charsIn),$charsOut)"/>
      <xsl:call-template name="replaceCharsInString">
        <xsl:with-param name="stringIn" select="substring-after($stringIn,$charsIn)"/>
        <xsl:with-param name="charsIn" select="$charsIn"/>
        <xsl:with-param name="charsOut" select="$charsOut"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$stringIn"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>