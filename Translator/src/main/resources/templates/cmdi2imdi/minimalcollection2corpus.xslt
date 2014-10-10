<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tla="http://tla.mpi.nl"
	version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <!-- 
        Written by: Twan Goosen
        Date: 10 October 2014
    -->
    
    <xsl:template name="MINIMALCOLLECTION2CORPUS">
        <METATRANSCRIPT xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"            
            FormatId="IMDI 3.0"
            Type="CORPUS"
            Version="0"
            xsi:schemaLocation="http://www.mpi.nl/IMDI/Schema/IMDI http://www.mpi.nl/IMDI/Schema/IMDI_3.0.xsd">
            <xsl:attribute name="Date"><xsl:value-of select="$datum"/></xsl:attribute>
            <xsl:attribute name="ArchiveHandle">
                <xsl:value-of select="tla:getHandle(//Header/MdSelfLink, 'imdi')"/>
            </xsl:attribute>            
            <xsl:attribute name="Originator">
                <xsl:value-of select="tla:create-originator('minimalcollection2corpus.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Corpus>
                <xsl:apply-templates select="//collection/GeneralInfo" mode="MINCOLLECTION2CORPUS"/>
                <xsl:apply-templates select="//ResourceProxy" mode="MINCOLLECTION2CORPUS"/>
            </Corpus>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="ResourceProxy" mode="MINCOLLECTION2CORPUS">
         <xsl:choose>
             <xsl:when test="child::ResourceType = 'Metadata'">
                 <CorpusLink Name="">
                     <xsl:variable name="handle" select="tla:getHandle(ResourceRef, 'imdi')"/>
                     <xsl:if test="string-length($handle) > 0">
                         <xsl:attribute name="ArchiveHandle" select="tla:getHandle(ResourceRef, 'imdi')" />
                     </xsl:if>
                     <xsl:value-of select="tla:getTranslationUri(ResourceRef, 'imdi')"/>
                 </CorpusLink>
             </xsl:when>
          </xsl:choose> 
    </xsl:template>
    
    <xsl:template match="GeneralInfo" mode="MINCOLLECTION2CORPUS">
        <Name>
            <xsl:value-of select="Name"/>
        </Name>
        <Title>
            <xsl:value-of select="Title"/>
        </Title>
        <Description>
        <!-- TODO: Pick from these elements
            <CMD_Element name="ID" ConceptLink="http://www.isocat.org/datcat/DC-2573" ValueScheme="string" CardinalityMin="0" CardinalityMax="unbounded"/>
            <CMD_Element name="Version" ConceptLink="http://www.isocat.org/datcat/DC-2547" ValueScheme="string" CardinalityMin="0" CardinalityMax="1"/>
            <CMD_Element name="Owner" ConceptLink="http://www.isocat.org/datcat/DC-2956" ValueScheme="string" CardinalityMin="0" CardinalityMax="unbounded" Multilingual="true"/>
            <CMD_Element name="PublicationYear" ConceptLink="http://www.isocat.org/datcat/DC-2538" ValueScheme="gYear" CardinalityMin="0" CardinalityMax="1"/>
            <CMD_Component name="TimeCoverage" ConceptLink="http://www.isocat.org/datcat/DC-2502" CardinalityMin="0" CardinalityMax="1">
                <CMD_Element name="Description" ValueScheme="string" CardinalityMin="0" CardinalityMax="1"/>
                <CMD_Element name="minDate" ValueScheme="date" CardinalityMin="0" CardinalityMax="1"/>
                <CMD_Element name="maxDate" ValueScheme="date" CardinalityMin="0" CardinalityMax="1"/>
            </CMD_Component>
            <CMD_Component name="Description" ComponentId="clarin.eu:cr1:c_1271859438118" ConceptLink="http://www.isocat.org/datcat/DC-2520" CardinalityMin="0" CardinalityMax="1" />
        -->
        </Description>

    </xsl:template>

</xsl:stylesheet>