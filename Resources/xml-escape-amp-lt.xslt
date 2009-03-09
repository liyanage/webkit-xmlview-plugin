<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="no"/>


<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="text()[contains(., '&amp;') or contains(., '&lt;')]">
<xsl:call-template name="escape">
	<xsl:with-param name="string" select="string(.)"/>
</xsl:call-template>
</xsl:template>

<xsl:template match="@*[contains(string(.), '&amp;') or contains(string(.), '&lt;')]">
<xsl:attribute name="{name()}" namespace="{namespace-uri()}">
	<xsl:call-template name="escape">
		<xsl:with-param name="string" select="string(.)"/>
	</xsl:call-template>
</xsl:attribute>
</xsl:template>


<xsl:template name="escape">
<xsl:param name="string"/>
<xsl:variable name="amp_escaped">
    <xsl:call-template name="replaceCharsInString">
      <xsl:with-param name="stringIn" select="$string"/>
      <xsl:with-param name="charsIn" select="'&amp;'"/>
      <xsl:with-param name="charsOut" select="'&amp;amp;'"/>
    </xsl:call-template>
</xsl:variable>
<xsl:call-template name="replaceCharsInString">
  <xsl:with-param name="stringIn" select="$amp_escaped"/>
  <xsl:with-param name="charsIn" select="'&lt;'"/>
  <xsl:with-param name="charsOut" select="'&amp;lt;'"/>
</xsl:call-template>
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