<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output
	method="xml"
	version="1.0"
	encoding="utf-8"
	indent="no"
	doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
	doctype-public="-//W3C//DTD XHTML 1.1//EN"
/>

<xsl:param name="resource_base"/>

<xsl:template match="/">
	<html>
		<head>
			
			<style type='text/css'>
				body {
					font-family: monospace;
				}
				
				div.comment {
					color: #555;
					white-space: pre;
				}
				
				div.xmlpi {
					color: red;
				}
				
				div.mixedcontent {
					margin-left: 10px;
				}
				
				span.tag {
					color: #11a;
				}
				
				span.attribute.name {
					color: #080;
				}

				span.attribute.value {
					color: black;
				}
				
				span.namespace {
					color: #88f;
				}
				
				span.text {
					white-space: pre;
				}
			</style>
			
		</head>
		<body><xsl:apply-templates/></body>
		
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


<!-- elements that have mixed content -->
<xsl:template match="*[*|comment()|processing-instruction()]">
	<div class='element'>
	<span class='tag open'>&lt;<xsl:value-of select="name()"/><xsl:call-template name='namespaces'/><xsl:apply-templates select="@*"/>></span>
	<div class='mixedcontent'>
		<xsl:apply-templates/>
	</div>
	<span class='tag close'>&lt;/<xsl:value-of select="name()"/>></span>
	</div>
</xsl:template>


<!-- elements that have only text content -->
<xsl:template match="*">
	<div class='element'>
	<span class='tag open'>&lt;<xsl:value-of select="name()"/><xsl:call-template name='namespaces'/><xsl:apply-templates select="@*"/>></span><xsl:apply-templates/><span class='tag close'>&lt;/<xsl:value-of select="name()"/>></span>
	</div>
</xsl:template>

<xsl:template match="*[not(node())]">
	<div class='element'>
	<span class='tag selfclosed'>&lt;<xsl:value-of select="name()"/><xsl:call-template name='namespaces'/><xsl:apply-templates select="@*"/>/></span>
	</div>
</xsl:template>


<xsl:template match="@*">
	<xsl:text> </xsl:text><span class='attribute name'><xsl:value-of select="name()"/></span>=<xsl:apply-templates select="." mode="attrvalue"/>
</xsl:template>

<xsl:template match='@*[contains(., "&apos;")]' mode='attrvalue'>"<span class='attribute value'><xsl:value-of select="."/></span>"</xsl:template>

<xsl:template match='@*[not(contains(., "&apos;"))]' mode='attrvalue'>'<span class='attribute value'><xsl:value-of select="."/></span>'</xsl:template>


<xsl:template name="namespaces">
	<xsl:if test="namespace-uri()">
		<xsl:variable name="my_ns" select="namespace-uri()" />
		<xsl:if test="not(ancestor::*[namespace-uri() = $my_ns])">
			<xsl:variable name="prefix" select="substring-before(name(), local-name())" />
		
			<span class='namespace'> xmlns<xsl:if test="$prefix">:<xsl:value-of select="substring-before($prefix, ':')"/></xsl:if>='<xsl:value-of select="namespace-uri()"/>'</span>
		</xsl:if>
	</xsl:if>
</xsl:template>




</xsl:stylesheet>