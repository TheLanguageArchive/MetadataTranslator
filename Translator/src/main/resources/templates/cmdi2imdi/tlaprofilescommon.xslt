<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tla="http://tla.mpi.nl"
    xmlns:lat="http://lat.mpi.nl/"
    version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template match="descriptions|Descriptions" mode="COMMONTLA2IMDISESSION">
        <xsl:for-each select="Description">
            <xsl:choose>
                <xsl:when test="normalize-space(.)!=''">                    
                    <Description>
                        <xsl:choose>
                            <xsl:when test="normalize-space(@xml:lang)!=''">
                                <xsl:choose>
                                    <xsl:when test="@xml:lang = 'nl'">
                                        <xsl:attribute name="LanguageId">ISO639-3:nld</xsl:attribute>
                                    </xsl:when>
                                    <xsl:when test="@xml:lang = 'en'">
                                        <xsl:attribute name="LanguageId">ISO639-3:eng</xsl:attribute>
                                    </xsl:when>
                                    <xsl:when test="string-length(@xml:lang)=3">
                                        <xsl:attribute name="LanguageId" select="concat('ISO639-3:',@xml:lang)" /> <!-- this probably needs to be more sophisticated to cover all cases -->                                        
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message>WARN: encountered xml:lang attribute with a length != 3, skipped.</xsl:message>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </xsl:when>
                        </xsl:choose>                
                        <xsl:value-of select="."/>
                    </Description>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>