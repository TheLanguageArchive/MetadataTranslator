<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tla="http://tla.mpi.nl"
    xmlns:lat="http://lat.mpi.nl/" version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">

    <xsl:template match="descriptions|Descriptions" mode="COMMONTLA2IMDISESSION">
        <xsl:for-each select="Description">
            <xsl:choose>
                <xsl:when test="normalize-space(.)!=''">
                    <Description>
                        <xsl:call-template name="create-description-language-attribute"/>
                        <xsl:value-of select="."/>
                    </Description>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="create-description-language-attribute">
        <xsl:if test="normalize-space(@xml:lang)!=''">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'nl'">
                    <xsl:attribute name="LanguageId">ISO639-3:nld</xsl:attribute>
                </xsl:when>
                <xsl:when test="@xml:lang = 'en'">
                    <xsl:attribute name="LanguageId">ISO639-3:eng</xsl:attribute>
                </xsl:when>
                <xsl:when test="string-length(@xml:lang)=3">
                    <xsl:attribute name="LanguageId" select="concat('ISO639-3:',@xml:lang)"/>
                    <!-- this probably needs to be more sophisticated to cover all cases -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>WARN: encountered xml:lang attribute with a length != 3,
                        skipped.</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- InfoLink to Description with @ArchiveHandle and @Link -->
    <xsl:template match="InfoLink" mode="create-info-link-description">
        <xsl:variable name="proxy" select="//ResourceProxy[@id eq current()/@ref]"/>
        <xsl:choose>
            <xsl:when test="Description">
                <xsl:for-each select="Description">
                    <xsl:call-template name="create-info-link-description-element">
                        <xsl:with-param name="proxy" select="$proxy"/>
                        <xsl:with-param name="description" select="text()"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="create-info-link-description-element">
                    <xsl:with-param name="proxy" select="$proxy"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="create-info-link-description-element">
        <xsl:param name="proxy"/>
        <xsl:param name="description" required="no"/>
        <Description>
            <xsl:call-template name="create-description-language-attribute"/>

            <xsl:choose>
                <xsl:when test="$proxy">
                    <xsl:variable name="handle" select="tla:getBaseHandle($proxy/ResourceRef)"/>
                    <xsl:if test="$handle">
                        <xsl:attribute name="ArchiveHandle">
                            <xsl:value-of select="concat('hdl:',$handle)"/>
                        </xsl:attribute>
                    </xsl:if>

                    <xsl:variable name="localUri" select="$proxy/ResourceRef/@lat:localURI"/>
                    <xsl:if test="normalize-space($localUri) != ''">
                        <xsl:attribute name="Link">
                            <xsl:value-of select="resolve-uri($localUri, $source-location)"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>Warning: InfoLink without matching resource proxy! Description
                        content: [<xsl:value-of select="Description"/>]</xsl:message>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="$description">
                <xsl:value-of select="$description"/>
            </xsl:if>
        </Description>
    </xsl:template>
</xsl:stylesheet>
