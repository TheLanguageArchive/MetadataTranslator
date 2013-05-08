<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tla="http://tla.mpi.nl">
    
    <xsl:function name="tla:getHandle">
        <xsl:param name="handlevalue" />
        <xsl:param name="outformat"/>
        <xsl:choose>
            <xsl:when test="starts-with($handlevalue, 'hdl:')">
                <xsl:value-of select="concat($handlevalue, '@format=', $outformat)" /></xsl:when>
            <xsl:when test="starts-with($handlevalue, 'http://hdl.handle.net/')">
                <xsl:value-of select="concat(replace($handlevalue, 'http://hdl\.handle\.net/', 'hdl:'), '@format=', $outformat)" /></xsl:when>
            <!-- otherwise return nothing -->
        </xsl:choose>
    </xsl:function>

    <xsl:function name="tla:getHandleOrTranslationUri">
        <xsl:param name="handlevalue" />
        <xsl:param name="outformat"/>
        <xsl:variable name="corpuslinkhref" select="tla:getHandle($handlevalue, 'imdi')"/>
        <xsl:choose>
            <xsl:when test="$corpuslinkhref"><xsl:value-of select="$corpuslinkhref"/></xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($service-base-uri, '?in=', encode-for-uri(resolve-uri($handlevalue, $source-location)), '&amp;outFormat=', $outformat)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
