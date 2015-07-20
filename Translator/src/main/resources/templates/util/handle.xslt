<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tla="http://tla.mpi.nl"
    xmlns:cmd="http://www.clarin.eu/cmd/"
    xmlns:lat="http://lat.mpi.nl/">
    
    <!-- 
        If the provided href is a handle, returns it has handle (always with hdl:-prefix). 
        If it is not a handle, returns nothing for easy testing.
    -->
    <xsl:function name="tla:getHandleWithoutFormat">
        <xsl:param name="href" />
        <xsl:param name="outformat" />
        <xsl:variable name="baseHandle" select="tla:getBaseHandle($href)" />
        <xsl:if test="$baseHandle">
            <xsl:value-of select="concat('hdl:',replace($baseHandle,'@format=.+$',''), '@format=', $outformat)" />
        </xsl:if>
        <!-- otherwise return nothing -->
    </xsl:function>
    <xsl:function name="tla:getHandle">
        <xsl:param name="href" />
        <xsl:param name="outformat"/>
        <xsl:variable name="baseHandle" select="tla:getBaseHandle($href)" />
        <xsl:if test="$baseHandle">
            <xsl:value-of select="concat('hdl:',$baseHandle, '@format=', $outformat)" />
        </xsl:if>
        <!-- otherwise return nothing -->
    </xsl:function>
    
    <!--
        Returns a 'base' handle without prefix if the provided href is a handle (i.e. starts with hdl: or http://hdl.handle.net).
        Otherwise returns nothing.
    -->
    <xsl:function name="tla:getBaseHandle">
        <xsl:param name="href" />
        <xsl:choose>
            <xsl:when test="starts-with($href, 'hdl:')">
                <xsl:value-of select="replace($href, 'hdl:', '')" /></xsl:when>
            <xsl:when test="matches($href, '^http(s)://hdl.handle.net/')">
                <xsl:value-of select="replace($href, 'http(s)://hdl\.handle\.net/', '')" /></xsl:when>
            <!-- otherwise return nothing -->
        </xsl:choose>
    </xsl:function>


    <!--
        If the provided href is a handle, returns the handle. Otherwise returns a link to the translation service 
        with the provided href as input parameter and the provided outformat as output format.
    -->
    <xsl:function name="tla:getHandleOrTranslationUri">
        <xsl:param name="href" />
        <xsl:param name="outformat"/>
        <xsl:variable name="handle" select="tla:getHandle($href, 'imdi')"/>
        <xsl:choose>
            <xsl:when test="$handle"><xsl:value-of select="$handle"/></xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="tla:getTranslationUri($href, $outformat)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
        Returns a reference to the translation service with the provided href as input parameter and the provided outformat
        as output format. If href is a handle, it will be included as a 'base handle'.
    -->
    <xsl:function name="tla:getTranslationUri">
        <xsl:param name="href" />
        <xsl:param name="outformat"/>
        <xsl:variable name="handle" select="tla:getBaseHandle($href)"/>
        <xsl:choose>
            <xsl:when test="$handle">
                <!-- HREF is a handle; use as input for translation service -->
                <xsl:value-of select="concat($service-base-uri, '?in=', $handle, '&amp;outFormat=', $outformat)"/></xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($service-base-uri, '?in=', encode-for-uri(resolve-uri($href, $source-location)), '&amp;outFormat=', $outformat)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--
        Returns either the localURI value or, if that is empty/non-existant, returns the handle.
        The input parameter is a ResourceProxy node.
    -->
    <xsl:function name="tla:getlocalURIorfallback">
        <xsl:param name="resproxy"/>
        <xsl:choose>
            <xsl:when test="normalize-space($resproxy/cmd:ResourceRef/@lat:localURI)!=''">
                <xsl:value-of select="$resproxy/cmd:ResourceRef/@lat:localURI"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$resproxy/cmd:ResourceRef"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
