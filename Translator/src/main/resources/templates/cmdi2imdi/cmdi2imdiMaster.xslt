<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:tla="http://tla.mpi.nl"
    xmlns:lat="http://lat.mpi.nl/"
    version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:include href="tlaprofilescommon.xslt"/>
    <xsl:include href="iprosla2imdi.xslt"/>
    <xsl:include href="valid2imdi.xslt"/>
    <xsl:include href="collection2corpus.xslt"/>
    <xsl:include href="tlacollection2corpus.xslt"/>
    <xsl:include href="tlasession2imdisession.xslt"/>
    <xsl:include href="silangsession2imdisession.xslt"/>
    <xsl:include href="dbdsession2imdisession.xslt"/>
    <xsl:include href="discanproject2corpus.xslt"/>
    <xsl:include href="discantextcorpus2corpus.xslt"/>
    <xsl:include href="discancase2imdi.xslt"/>
    <xsl:include href="soundbites2imdi.xslt"/>
    <xsl:include href="leslla2imdi.xslt"/>
    <xsl:include href="dlucea2imdi.xslt"/>
    <xsl:include href="sltla2imdi.xslt"/>
    <xsl:include href="bat2imdisession.xslt"/>    
    <xsl:include href="talkbank2session.xslt"/>
    <xsl:include href="talkbankcollection2corpus.xslt"/>
    <xsl:include href="../util/identity.xslt"/>
    <xsl:include href="../util/handle.xslt"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    
    <xsl:param name="datum" select="//MdCreationDate" />
    
    <xsl:param name="service-base-uri" select="'http://lux16.mpi.nl/ds/TranslationService/translate'"/>
    <xsl:param name="source-location" select="base-uri()"/>
    
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1331113992512/xsd')">
                <xsl:call-template name="IPROSLA2IMDI"/>
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1396012485083/xsd')">
                <xsl:call-template name="VALID2IMDI"/>
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1345561703620/xsd')">
                <xsl:call-template name="COLLECTION2CORPUS" />
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1407745712064/xsd')">
                <xsl:call-template name="TLACOLLECTION2CORPUS" />
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1407745712035/xsd')">
                <xsl:call-template name="TLASESSION2IMDISESSION" />
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1391763610422/xsd')">
                <xsl:call-template name="DBDSESSION2IMDISESSION" />
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1417617523856/xsd')">
                <xsl:call-template name="SILANGSESSION2IMDISESSION" />
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1361876010525/xsd')">
                <xsl:call-template name="DISCANPROJECT2CORPUS" />
            </xsl:when>            
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1361876010653/xsd')">
                <xsl:call-template name="DISCANTEXTCORPUS2CORPUS" />
            </xsl:when>            
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1366895758243/xsd')">
                <xsl:call-template name="DISCANCASE2IMDI" />
            </xsl:when> 
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1328259700928/xsd')">
                <xsl:call-template name="SOUNDBITES2IMDI" />
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1375880372947/xsd')">
                <xsl:call-template name="LESLLA2IMDI" />
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1337778924955/xsd')">
                <xsl:call-template name="DLUCEA2IMDI" />
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1430905751641/xsd')">
                <xsl:call-template name="SLTLA2IMDI"/>
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1456409483202/xsd')">
                <xsl:call-template name="BAT2IMDISESSION" />
            </xsl:when>            
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1345561703620/xsd')">
                <xsl:call-template name="TALKBANKCOLLECTION2CORPUS"/>
            </xsl:when>
            <xsl:when test="matches(/CMD/@xsi:schemaLocation, 'http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/(1\.1/)?profiles/clarin.eu:cr1:p_1393514855466/xsd')">
                <xsl:call-template name="TALKBANK2IMDI"/>
            </xsl:when>
            
            <!-- Add new profile templates here -->
			<!--        
			<xsl:when test="exists(//Components/WHAT-EVER)">
                <xsl:call-template name="WHATEVER2IMDI"/>
            </xsl:when>
            -->
            <!-- Not a known profile! Apply identity -->
            <xsl:otherwise>
                <xsl:message>No matching stylesheet for input file, falling back to identity transform. 
                    <xsl:choose>
                        <xsl:when test="/CMD/@xsi:schemaLocation">
                            <xsl:text>Found schema location: </xsl:text>
                            <xsl:value-of select="/CMD/@xsi:schemaLocation"></xsl:value-of>
                            <xsl:text></xsl:text></xsl:when>
                        <xsl:otherwise>
                            <xsl:text>No schema location found!</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    </xsl:message>
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
        <!-- ResourceRef is usually a handle, check this -->
        <xsl:variable name="handle" select="tla:getBaseHandle(ResourceRef)"/>
        <xsl:choose>
            <xsl:when  test="$handle">
                <!-- We found a handle; put it in the attribute -->
                <xsl:attribute name="ArchiveHandle">
                    <xsl:value-of select="concat('hdl:',$handle)"/>
                </xsl:attribute>
                
                <!-- See if we have a URL to use as ResourceLink element content -->
                <xsl:variable name="localUri" select="ResourceRef/@lat:localURI" />
                <!-- Assuming the ResourceRef content is not a handle... -->
                <xsl:if test="$localUri">
                    <xsl:value-of select="resolve-uri(ResourceRef/@lat:localURI, $source-location)"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!-- Content is not a handle, make sure it is absolute and skip the ArchiveHandle -->
                <xsl:value-of select="resolve-uri(ResourceRef,$source-location)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>