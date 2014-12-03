<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs iso"
	version="2.0"
	xmlns:iso="http://www.iso.org/">
	
  <!-- see: http://www.sil.org/iso639-3/ (download) -->
  <xsl:param name="pathToTAB" select="'http://www-01.sil.org/iso639%2D3/iso-639-3.tab'"/>
	
	<xsl:function name="iso:getTokens" as="xs:string+">
		<xsl:param name="str" as="xs:string" />
		<xsl:analyze-string select="concat($str, '\t')" regex='(("[^"]*")+|[^\t]*)\t'>
			<xsl:matching-substring>
				<xsl:sequence select='replace(regex-group(1), "^""|""$|("")""", "$1")' />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>
	
	<xsl:template name="main">
		<xsl:variable name="doc" as="element(root)">
			<xsl:choose>
				<xsl:when test="unparsed-text-available($pathToTAB)">
					<xsl:variable name="tab" select="unparsed-text($pathToTAB)" />
					<xsl:variable name="lines" select="tokenize($tab, '\r\n')" as="xs:string+" />
					<xsl:variable name="elemNames" select="iso:getTokens($lines[1])" as="xs:string+" />
					<root>
						<xsl:for-each select="$lines[position() &gt; 1][normalize-space(.)!='']">
							<row>
								<xsl:variable name="lineItems" select="iso:getTokens(.)" as="xs:string+" />
								
								<xsl:for-each select="$elemNames">
									<xsl:variable name="pos" select="position()" />
									<elem name="{.}">
										<xsl:value-of select="$lineItems[$pos]" />
									</elem>
								</xsl:for-each>
							</row>
						</xsl:for-each>
					</root>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">ERR: couldn't load: <xsl:value-of select="$pathToTAB" /></xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:apply-templates select="$doc"/>
	</xsl:template>
	
	<xsl:template match="root">
		<m xmlns="http://www.iso.org/">
			<xsl:apply-templates/>
		</m>
	</xsl:template>
	
	<xsl:template match="row[normalize-space(.)='']" priority="1"/>
	
	<xsl:template match="row">
		<e>
			<xsl:apply-templates/>
		</e>
	</xsl:template>
	
	<xsl:template match="elem[normalize-space(.)='']" priority="2"/>
	
	<xsl:template match="elem[@name='Id']" priority="1">
		<i>
			<xsl:value-of select="."/>
		</i>
	</xsl:template>
	
	<xsl:template match="elem[@name='Part2B']" priority="1">
		<b>
			<xsl:value-of select="."/>
		</b>
	</xsl:template>
	
	<xsl:template match="elem[@name='Part2T']" priority="1">
		<t>
			<xsl:value-of select="."/>
		</t>
	</xsl:template>
	
	<xsl:template match="elem[@name='Part1']" priority="1">
		<o>
			<xsl:value-of select="."/>
		</o>
	</xsl:template>
	
	<xsl:template match="elem[@name='Ref_Name']" priority="1">
		<n>
			<xsl:value-of select="."/>
		</n>
	</xsl:template>
	
	<xsl:template match="elem"/>
</xsl:stylesheet>
