<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:tla="http://tla.mpi.nl"
    xmlns:lat="http://lat.mpi.nl/"
    version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:include href="iprosla2imdi.xslt"/>
    <xsl:include href="collection2corpus.xslt"/>
    <xsl:include href="tlacollection2corpus.xslt"/>
    <xsl:include href="tlasession2imdisession.xslt"/>
    <xsl:include href="discanproject2corpus.xslt"/>
    <xsl:include href="discantextcorpus2corpus.xslt"/>
    <xsl:include href="discancase2imdi.xslt"/>
    <xsl:include href="soundbites2imdi.xslt"/>
    <xsl:include href="leslla2imdi.xslt"/>
    <xsl:include href="../util/identity.xslt"/>
    <xsl:include href="../util/handle.xslt"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    
    <xsl:param name="datum" select="//MdCreationDate" />
    
    <xsl:param name="service-base-uri" select="'http://lux16.mpi.nl/ds/TranslationService/translate'"/>
    <xsl:param name="source-location" select="base-uri()"/>
    
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="contains(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1331113992512/xsd')">
                <xsl:call-template name="IPROSLA2IMDI"/>
            </xsl:when>
            <xsl:when test="contains(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1345561703620/xsd')">
                <xsl:call-template name="COLLECTION2CORPUS" />
            </xsl:when>
            <xsl:when test="contains(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1407745712064/xsd')">
                <xsl:call-template name="TLACOLLECTION2CORPUS" />
            </xsl:when>
            <xsl:when test="contains(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1407745712035/xsd')">
                <xsl:call-template name="TLASESSION2IMDISESSION" />
            </xsl:when>
            <xsl:when test="contains(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1361876010525/xsd')">
                <xsl:call-template name="DISCANPROJECT2CORPUS" />
            </xsl:when>            
            <xsl:when test="contains(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1361876010653/xsd')">
                <xsl:call-template name="DISCANTEXTCORPUS2CORPUS" />
            </xsl:when>            
            <xsl:when test="contains(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1366895758243/xsd')">
                <xsl:call-template name="DISCANCASE2IMDI" />
            </xsl:when> 
            <xsl:when test="contains(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1328259700928/xsd')">
                <xsl:call-template name="SOUNDBITES2IMDI" />
            </xsl:when>
            <xsl:when test="contains(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1375880372947/xsd')">
                <xsl:call-template name="LESLLA2IMDI" />
            </xsl:when>
            
            
            <!-- Add new profile templates here -->
			<!--        
			<xsl:when test="exists(//Components/WHAT-EVER)">
                <xsl:call-template name="WHATEVER2IMDI"/>
            </xsl:when>
            -->
            <!-- Not a known profile! Apply identity -->
            <xsl:otherwise>
                <xsl:call-template name="identity-transform"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:function name="tla:create-originator">
        <xsl:param name="schema-name" />
        <xsl:param name="self-link" />
        <xsl:choose>
            <xsl:when test="string-length($self-link) &gt; 0">
                <xsl:value-of select="concat('Metadata Translator: ', $schema-name, ' ', $self-link)" />                    
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('Metadata Translator: ', $schema-name, ' ', $source-location)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="ResourceProxy" mode="create-resource-link-content">
        <xsl:variable name="handle" select="tla:getBaseHandle(ResourceRef)"/>
        <xsl:choose>
            <xsl:when  test="$handle">
                <xsl:attribute name="ArchiveHandle">
                    <xsl:value-of select="concat('hdl:',$handle)"/>
                </xsl:attribute>
                <xsl:variable name="localUri" select="ResourceRef/@lat:localURI" />
                <xsl:if test="$localUri">
                    <xsl:value-of select="ResourceRef/@lat:localURI"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ResourceRef"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>