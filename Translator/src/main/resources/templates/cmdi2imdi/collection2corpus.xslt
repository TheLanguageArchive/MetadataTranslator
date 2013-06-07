<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tla="http://tla.mpi.nl"
	version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template name="COLLECTION2CORPUS">
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
                <xsl:value-of select="tla:create-originator('collection2corpus.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Corpus>
                <xsl:apply-templates select="//collection" mode="COLLECTION2CORPUS"/>
                <xsl:apply-templates select="//ResourceProxy" mode="COLLECTION2CORPUS"/>
            </Corpus>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="ResourceProxy" mode="COLLECTION2CORPUS">
         <xsl:choose>
             <xsl:when test="child::ResourceType = 'Metadata'">
                 <CorpusLink Name="">
                     <xsl:variable name="handle" select="tla:getHandle(ResourceRef, 'imdi')"/>
                     <xsl:if test="string-length($handle) > 0">
                         <xsl:attribute name="ArchiveHandle" select="tla:getHandle(ResourceRef, 'imdi')" />
                     </xsl:if>
                     <xsl:value-of select="concat($service-base-uri, '?in=', encode-for-uri(resolve-uri(ResourceRef, $source-location)), '&amp;outFormat=imdi')"/>
                 </CorpusLink>
             </xsl:when>
          </xsl:choose> 
    </xsl:template>
    
    <xsl:template match="collection" mode="COLLECTION2CORPUS">
        <Name>
            <xsl:value-of select="CollectionInfo/Name"/>
        </Name>
        <Title/>        
        <Description LanguageId="" Link="">
            <xsl:value-of select="CollectionInfo/Description/Description"/>
        </Description>       
    </xsl:template>

</xsl:stylesheet>