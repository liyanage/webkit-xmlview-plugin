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
					color: #77e;
				}
				
				span.namespace {
					color: #c55;
				}
				
				/*
				div.name_style span.text {
					white-space: pre;
				}
				*/
				
				
				/*
				span.text {
					white-space: pre;
				}
				*/
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


<!-- elements with mixed content -->
<xsl:template match="*[*|comment()|processing-instruction()]">
	<xsl:variable name="lname" select="concat('name_', local-name())" />
	<div class='element {$lname}'>
	<span class='tag open {$lname}'>&lt;<xsl:value-of select="name()"/><xsl:call-template name='namespaces'/><xsl:apply-templates select="@*"/>></span>
	<div class='mixedcontent'>
		<xsl:apply-templates/>
	</div>
	<span class='tag close {$lname}'>&lt;/<xsl:value-of select="name()"/>></span>
	</div>
</xsl:template>


<!-- elements without mixed content -->
<xsl:template match="*">
	<xsl:variable name="lname" select="concat('name_', local-name())" />
	<div class='element {$lname}'>
	<span class='tag open {$lname}'>&lt;<xsl:value-of select="name()"/><xsl:call-template name='namespaces'/><xsl:apply-templates select="@*"/>></span><xsl:apply-templates/><span class='tag close {$lname}'>&lt;/<xsl:value-of select="name()"/>></span>
	</div>
</xsl:template>


<!-- empty elements -->
<xsl:template match="*[not(node())]">
	<xsl:variable name="lname" select="concat('name_', local-name())" />
	<div class='element {$lname}'>
	<span class='tag selfclosed {$lname}'>&lt;<xsl:value-of select="name()"/><xsl:call-template name='namespaces'/><xsl:apply-templates select="@*"/>/></span>
	</div>
</xsl:template>


<xsl:template match="@*">
	<xsl:text> </xsl:text><span class='attribute name'><xsl:value-of select="name()"/></span>=<xsl:apply-templates select="." mode="attrvalue"/>
</xsl:template>

<!-- Try to produce correct markup for all single/double quote combinations in attribute values -->
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
		<!-- emit a namespace declaration if this element or attribute has a namespace and no ancestor defines it -->
		<xsl:if test="$my_ns and not(ancestor::*[namespace-uri() = $my_ns])">
			<xsl:variable name="prefix" select="substring-before(name(), local-name())"/>
			<span class='namespace'> xmlns<xsl:if test="$prefix">:<xsl:value-of select="substring-before($prefix, ':')"/></xsl:if>='<xsl:value-of select="namespace-uri()"/>'</span>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!-- string search/replace, from http://www.dpawson.co.uk/xsl/sect2/replace.html -->
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